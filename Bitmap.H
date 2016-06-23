#ifndef BITMAP
#define BITMAP

#include <iostream>
#include <fstream>
#include <vector>

using namespace std;

typedef unsigned char byte;

struct Bitmap
{
  Bitmap(size_t addr = 0x2000)
  :addr_lo(addr&255),addr_hi(addr/256)
  {
    fill(0);
  }
  
  void clear()
  {
    fill(0);
  }

  void fill(byte b)
  {
    for (size_t i = 8000; i-->0;)
    {
      bitmap[i] = b;
    }
  }

  void fill(const vector<byte>& p)
  {
    for (size_t i = 8000; i-->0;)
    {
      bitmap[i] = p[i%p.size()];
    }
  }

  byte operator[](size_t addr) const
  {
    return (0<=addr && addr<8000) ? bitmap[addr] : 0;
  }

  byte& operator[](size_t addr)
  {
    static byte null = 0;
    return (0<=addr && addr<8000) ? bitmap[addr] : null;
  }

  Bitmap operator!() const
  {
    Bitmap inv = *this;
    for (size_t i = 0; i<8000; ++i)
    {
      inv.bitmap[i] ^= 255;
    }
    return inv;
  }

  Bitmap& operator|=(const Bitmap& o)
  {
    for (size_t i = 0; i<8000; ++i)
    {
      bitmap[i] |= o.bitmap[i];
    }
    return *this;
  }

  Bitmap operator|(const Bitmap& o) const
  {
    Bitmap ret = *this;
    ret|=o;
    return ret;
  }

  Bitmap& operator&=(const Bitmap& o)
  {
    for (size_t i = 0; i<8000; ++i)
    {
      bitmap[i] &= o.bitmap[i];
    }
    return *this;
  }

  Bitmap operator&(const Bitmap& o) const
  {
    Bitmap ret = *this;
    ret&=o;
    return ret;
  }

  Bitmap& operator^=(const Bitmap& o)
  {
    for (size_t i = 0; i<8000; ++i)
    {
      bitmap[i] ^= o.bitmap[i];
    }
    return *this;
  }

  Bitmap operator^(const Bitmap& o) const
  {
    Bitmap ret = *this;
    ret^=o;
    return ret;
  }

  bool operator==(const Bitmap& o) const
  {
    for (size_t i = 0; i<8000; ++i)
    {
      if (bitmap[i]!=o.bitmap[i])
      {
        return false;
      }
    }
    return true;
  }

  bool operator!=(const Bitmap& o) const
  {
    return !operator==(o);
  }

  void save(string file) const
  {
    filebuf fb;
    fb.open (file.data(),ios::out);
    fb.sputn((char*)this,sizeof(Bitmap));
    fb.close();
  }

  void load(string file)
  {
    filebuf fb;
    fb.open (file.data(),ios::in);
    fb.sgetn((char*)this,sizeof(Bitmap));
    fb.close();
  }

  void saveBMP(string file) const
  {
    static byte header[] = {
      0x42, 0x4d, 0x7e, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3e, 0x00, 0x00, 0x00, 0x28, 0x00,
      0x00, 0x00, 0x40, 0x01, 0x00, 0x00, 0xc8, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x40, 0x1f, 0x00, 0x00, 0x12, 0x0b, 0x00, 0x00, 0x12, 0x0b, 0x00, 0x00, 0x02, 0x00,
      0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
      };
    filebuf fb;
    fb.open (file.data(),ios::out);
    fb.sputn((char*)header,62);
    for (size_t y = 200; y-->0;)
    {
      size_t line = (y/8)*320+(y%8);
      for (size_t x = 0; x<40; ++x)
      {
        fb.sputc((char)bitmap[line+x*8]);
      }
    }
    fb.close();
  }

  void loadBMP(string file)
  {
    byte data[8062];
    filebuf fb;
    fb.open (file.data(),ios::in);
    //header+bitmap
    if (fb.sgetn((char*)data,8062)!=8062)
    {
      cerr << file << " is not in the expected format." << endl;
    }
    fb.close();
    size_t p = 62;
    for (size_t y = 200; y-->0;)
    {
      size_t line = (y/8)*320+(y%8);
      for (size_t x = 0; x<40; ++x)
      {
        bitmap[line+x*8] = data[p++];
      }
    }
  }

private:

  byte addr_lo, addr_hi;
  byte bitmap[8000];
};

#endif //BITMAP
