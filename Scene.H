#ifndef SCENE
#define SCENE

#include "BitmapObject.H"
#include "Code.H"
#include <map>
#include <vector>
#include <string>
#include <iostream>
#include <sstream>
#include <fstream>

struct Scene
{
  Scene(string n = "scene" , size_t addr = 0xc000)
  :name(n)
  ,bg_addr(addr)
  {
  }

  void addBitmapObject(int layer, const BitmapObject& bo)
  {
    layers[layer].push_back(bo);
  }

  //generare background bitmap, code and data
  void compile() const
  {
    Bitmap background(bg_addr);
    Layers layerz;
    optimizeLayers(background,layerz);
    Code allCode;
    Label2Data allData;
    for (size_t addr = 0; addr<8000; ++addr)
    {
	  //size_t addr = ((addr_%200)/8)*320 + (addr_%8) + (addr_/200)*8;
      Code code;
      Label2Data data;
      byte action = 0;
      byte bg = background[addr];
      for (Layers::const_iterator lit = layerz.begin(); lit!=layerz.end(); ++lit)
      {
        int layer = lit->first;
        for (BitmapObjects::const_iterator boit = lit->second.begin(); boit!=lit->second.end(); ++boit)
        {
          const BitmapObject& bo = *boit;
          string bo_id = bo.name()+"_layer"+num(layer)+"_"+num(addr);
          //dynamic obj
          byte maxMask = bo.maxMask()[addr];
          if (maxMask)
          {
            if (!action && (bg==0))
            {
              //TODO: optimize const vector
              code.push_back(ldi_addr(bo.name()+"_phase"));
              code.push_back(lda_addr_i("bm_"+bo_id));
              data["bm_"+bo_id] = bo.bitmapPhases(addr);
            }
            else
            {
              //TODO: optimize const vector
              if (!action)
              {
                code.push_back(lda_byte(num(bg)));
              }
              code.push_back(ldi_addr(bo.name()+"_phase"));
              //TODO: optimize when the two arrays are the same: ora enough
              Bytes bmPhases = bo.bitmapPhases(addr);
              Bytes mskPhases = bo.maskPhases(addr);
              data["bm_"+bo_id] = bmPhases;
              if (bmPhases==inv(mskPhases))
              {
                code.push_back(ora_addr_i("bm_"+bo_id));
              }
              else
              {
                code.push_back(and_addr_i("msk_"+bo_id));
                code.push_back(ora_addr_i("bm_"+bo_id));
                data["msk_"+bo_id] = mskPhases;
              }
            }
            action |= maxMask;
          }
        }
      }
      if (action)
      {
        //TODO: optimize, same code different save addr
        code.push_back(sta_addr("bitmap+"+num(addr)));
        addCode(allCode,code);
        addData(allData,data);
      }
      background[addr] = bg;
      if ((addr%800)==0)
      {
        cout << "Progress: " << addr/80.0 << "%" << endl;
      }
    }
    openStream(name+"_code.asm");
    optimizeCode(allCode);
    printCode(allCode);
    print("rts");
    closeStream();
    openStream(name+"_data.asm");
    saveData(allData);
    closeStream();
    background.save(name+"_bg.prg");
    background.saveBMP(name+"_bg.bmp");
    cout << "Progress: 100%" << endl;
  }

  void save(bool prg = true, bool bmp = false) const
  {
    for (Layers::const_iterator lit = layers.begin(); lit!=layers.end(); ++lit)
    {
      int layer = lit->first;
      for (BitmapObjects::const_iterator boit = lit->second.begin(); boit!=lit->second.end(); ++boit)
      {
        const BitmapObject& bo = *boit;
        for (size_t i = 0; i<bo.phases(); ++i)
        {
          string id = name+"_"+bo.name()+"_layer"+num(layer)+"_phase"+num(i);
          if (prg)
          {
            bo.bitmap(i).save(id+"_bm.prg");
            bo.mask(i).save(id+"_msk.prg");
          }
          if (bmp)
          {
            bo.bitmap(i).saveBMP(id+"_bm.bmp");
            bo.mask(i).saveBMP(id+"_msk.bmp");
          }
        }
      }
    }
  }

  void preview(size_t phase, string file) const
  {
    Bitmap out;
    for (Layers::const_iterator lit = layers.begin(); lit!=layers.end(); ++lit)
    {
      for (BitmapObjects::const_iterator boit = lit->second.begin(); boit!=lit->second.end(); ++boit)
      {
        const BitmapObject& bo = *boit;
        int p = phase<bo.phases() ? phase : bo.phases()-1;
        out &= !bo.mask(p);
        out |= bo.bitmap(p);
      }
    }
    out.save(file+".prg");
    out.saveBMP(file+".bmp");
  }

private:

  typedef vector<byte>        Bytes;
  typedef map<string,Bytes>   Label2Data;
  typedef map<Bytes,string>   Data2Label;
  typedef list<pair<string,string> >  Alias;

  typedef vector<BitmapObject>    BitmapObjects;
  typedef map<int,BitmapObjects > Layers;


  static bool isConst(const Bytes& data)
  {
    for (size_t i = 0; i+1<data.size(); ++i)
    {
      if (data[i]!=data[i+1])
      {
        return false;
      }
    }
    return true;
  }

  static Bytes inv(const Bytes& data)
  {
    Bytes out = data;
    for (size_t i = 0; i<out.size(); ++i)
    {
      out[i]^=255;
    }
    return out;
  }


  static void addData(Label2Data& all, const Label2Data& data)
  {
    for (Label2Data::const_iterator it = data.begin(); it!=data.end(); ++it)
    {
      all[it->first] = it->second;
    }
  }

  static void addCode(Code& all, const Code& code)
  {
    for (Code::const_iterator it = code.begin(); it!=code.end(); ++it)
    {
      all.push_back(*it);
    }
  }

  template <typename N>
  static string num(const N& n)
  {
    stringstream ss (stringstream::out);
    ss << (long)n;
    return ss.str();
  }

  //remove always covered objects and data, merge static objects.
  void optimizeLayers(Bitmap& bg, Layers& layerz) const
  {
    bg.fill(0);
    //covers per layer
    map<int,Bitmap> cover;
    for (Layers::const_iterator lit = layers.begin(); lit!=layers.end(); ++lit)
    {
      Bitmap c;
      for (BitmapObjects::const_iterator boit = lit->second.begin(); boit!=lit->second.end(); ++boit)
      {
        c |= boit->minMask();
      }
      cover[lit->first] = c;
    }
    if (1)
    {
      Bitmap c;
      for (map<int,Bitmap>::reverse_iterator cit=cover.rbegin(); cit!=cover.rend(); ++cit)
      {
        Bitmap tmp = cit->second;
        cit->second = c;
        c|=tmp;
      }
    }
    //removing covered objects and data, merging static object into background
    for (Layers::const_iterator lit = layers.begin(); lit!=layers.end(); ++lit)
    {
      int layer = lit->first;
      const Bitmap& c = cover[layer];
      Bitmap ic = !c;
      BitmapObjects& objs = layerz[layer];
      for (BitmapObjects::const_iterator boit = lit->second.begin(); boit!=lit->second.end(); ++boit)
      {
        const BitmapObject& bo = *boit;
        if ((c|bo.maxMask())!=c)
        {
          BitmapObject obj = bo;
          obj.crop(ic);
          if (obj.phases()==1)
          {
            bg = (bg & (!obj.mask(0)) ) | obj.bitmap(0);
          }
          else
          {
            objs.push_back(obj);
          }
        }
      }
    }
  }

  void optimizeCode(Code& code) const
  {
    //we step in BLOCKs, but we optimize for WINDOW.
    const size_t BLOCK = 7;
    const size_t WINDOW = BLOCK+7;
    //TODO: optimize ldx/ldy
    vector<string> i_addr;
    vector<bool> i_reg;
    for (size_t i = 0; i<code.size(); ++i)
    {
      if (code[i].type=="i")  //ldx or ldy
      {
        i_addr.push_back(code[i].param);
        i_reg.push_back(code[i].selector=="x");
      }
    }
    string reg[2];
    for (size_t i = 0; i<i_addr.size(); i+=BLOCK)
    {
      size_t w = i_addr.size() - i;
      if (w>WINDOW) w = WINDOW; //optimization window size

      int best = 2*w;
      long best_p = -1;

      //brute force optimize for WINDOW
      for (long perm = 2<<w; perm-->0;)
      {
        long p = perm;
        int count = 0;
        string* r[2];
        r[0] = &reg[0];
        r[1] = &reg[1];
        for (size_t k = 0; k<w; ++k)
        {
          int ri = p%2;
          p>>=1;
          count += (*r[ri]!=i_addr[i+k]);
          r[ri] = &i_addr[i+k];
        }
        if (count<best)
        {
          best = count;
          best_p = perm;
        }
      }
      //use first BLOCK
      for (size_t k = 0; k<BLOCK && (i+k<i_addr.size()); ++k)
      {
        int ri = best_p%2;
        i_reg[i+k] = ri;
        reg[ri] = i_addr[i+k];
        best_p>>=1;
//cout << ri << " " << reg[ri] << endl;
      }
    }
    //updating x/y
    size_t k = 0;
    reg[0] = reg[1] = "";
    bool regi = 0;
    for (size_t i = 0; i<code.size(); ++i)
    {
      string type = code[i].type;
      if (type=="i")  //ldx or ldy
      {
        regi = i_reg[k];
        if (reg[regi]==i_addr[k])
        {
          code[i].selector = regi ? "sx" : "sy"; //skip
        }
        else
        {
          code[i].selector = regi ? "x" : "y";
          reg[regi] = i_addr[k];
        }
        k++;
      }
      else
      if (type=="a_i")
      {
        code[i].selector = regi ? "x" : "y";
      }
    }
  }

  void printCode(const Code& code) const
  {
    for (size_t i = 0; i<code.size(); ++i)
    {
      print(code[i].print());
    }
  }

  void print(const string& code) const
  {
    out << '\t' << code << endl;
  }


  static size_t compressData(Data2Label& data2label, Alias& alias)
  {
    Data2Label::iterator bestIt;
    Data2Label::iterator bestItMatch;
    size_t bestLength = 0;
    for (Data2Label::iterator it = data2label.begin(); it!=data2label.end(); ++it)
    {
      if (it->first.size()<=bestLength+1)
      {
        continue;
      }
      Bytes suffix = it->first;
      do
      {
        suffix.erase(suffix.begin());
        Data2Label::iterator mergeCand = data2label.upper_bound(suffix);
        if (mergeCand==it)
        {
          //periodical
          mergeCand++;
        }
        if (mergeCand!=data2label.end())
        {
          Bytes prefix = mergeCand->first;
          prefix.resize(suffix.size());
          if (suffix==prefix)
          {
            if (suffix.size()>bestLength)
            {
              bestIt = it;
              bestItMatch = mergeCand;
              bestLength = suffix.size();
            }
          }
        }
      } while(suffix.size()>bestLength+1);
    }
    if (bestLength)
    {
      string label = bestIt->second;
      Bytes mergeTo = bestIt->first;
      Bytes mergeFrom = bestItMatch->first;
      Bytes merged = mergeTo;
      //merging
      for (Bytes::iterator it = mergeFrom.begin()+bestLength; it!=mergeFrom.end(); ++it)
      {
        merged.push_back(*it);
      }
      //alias for mergeFrom
      alias.push_front(make_pair(bestItMatch->second,label + "+" + num(mergeTo.size()-bestLength)));
      //deleting old stuff
      data2label.erase(mergeTo);
      data2label.erase(mergeFrom);
      //adding merged
      data2label[merged] = label;
      
      //removing sub-vectors
      vector<Bytes> toRemove;
      for (Data2Label::iterator it = data2label.begin(); it!=data2label.end(); ++it)
      {
        if (it->first.size()<merged.size())
        {
          for (size_t j = 0; j+it->first.size()<=merged.size(); ++j)
          {
            bool eq = true;
            for (size_t k = 0; k<it->first.size(); ++k)
            {
              if (it->first[k]!=merged[j+k])
              {
                eq = false;
                break;
              }
            }
            //found sub-vector
            if (eq)
            {
cout << "sub-vector found" << endl;
              toRemove.push_back(it->first);
              alias.push_front(make_pair(it->second,label + "+" + num(j)));//or push_back?
            }
          }
        }
      }
      for (size_t i = 0; i<toRemove.size(); ++i)
      {
        data2label.erase(toRemove[i]);
        bestLength += toRemove[i].size();
      }
    }
    return bestLength;
  }

  void saveData(const Label2Data& data) const
  {
    Data2Label data2label;
    Alias alias;
    int dataCount = 0;

    for (Label2Data::const_iterator it = data.begin(); it!=data.end(); ++it)
    {
      Data2Label::const_iterator found(data2label.find(it->second));
      if (found==data2label.end())
      {
        data2label[it->second] = it->first;
      }
      else
      {
        alias.push_back(make_pair(it->first,found->second));
        dataCount += it->second.size();
      }
    }
    cout << "duplicate data: " << dataCount << endl;

    int opt = 0;
    dataCount = 0;
    cout << "compressing data ..." << endl;
    while (0<(opt = compressData(data2label,alias)))
    {
      dataCount += opt;
    }
    cout << "compressed data by overall: " << dataCount << endl;

    dataCount = 0;

    for (Data2Label::iterator it = data2label.begin(); it!=data2label.end();++it)
    {
      out << it->second << ":" << endl;
      for (size_t j = 0; j<it->first.size(); ++j)
      {
        if (j>0 && ((j%8)==0))
        {
          out << endl;
        }
        out << (((j%8)==0) ? "\tbyt " : ",") << num(it->first[j]);
      }
      out << endl;
      dataCount += it->first.size();
    }
    cout << "saved data: " << dataCount << endl;
    for (Alias::iterator it = alias.begin(); it!=alias.end(); ++it)
    {
      out << it->first << " = " << it->second << endl;
    }
  }

  mutable fstream out;

  void openStream(string file) const
  {
    out.open(file.data(),ios_base::out);
  }

  void closeStream() const
  {
    out.flush();
    out.close();
  }

  string  name;
  size_t  bg_addr;
  Layers  layers;
};

#endif
