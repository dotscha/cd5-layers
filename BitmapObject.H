#ifndef BITMAPOBJECT
#define BITMAPOBJECT

#include "Bitmap.H"
#include <vector>
#include <string>

struct BitmapObject
{
  BitmapObject(string name)
  :_name(name)
  {
    _minMask.fill(255);
  }

  BitmapObject(string name, const Bitmap& b)
  :_name(name)
  {
    _minMask.fill(255);
    addPhase(b);
  }

  string name() const { return _name; }

  size_t phases() const { return _bitmap.size();}

  void addPhase(const Bitmap& b, const Bitmap& m = !Bitmap())
  {
    _bitmap.push_back(b&m);
    _mask.push_back(m);
    _minMask&=m;
    _maxMask|=m;
  }

  void crop(const Bitmap& mask)
  {
    for (size_t i = 0; i<phases(); ++i)
    {
      _bitmap[i] &= mask;
      _mask[i] &= mask;
    }
    _minMask &= mask;
    _maxMask &= mask;
  }

  const Bitmap& bitmap(size_t phase) const { return _bitmap[phase]; }
  const Bitmap& mask(size_t phase)   const { return _mask[phase]; }

  const Bitmap& minMask() const { return _minMask;}
  const Bitmap& maxMask() const { return _maxMask;}

  vector<byte> bitmapPhases(size_t addr) const
  {
    vector<byte> out;
    for (size_t i=0; i<phases(); ++i)
    {
      out.push_back(_bitmap[i][addr]);
    }
    return out;
  }

  vector<byte> maskPhases(size_t addr) const
  {
    vector<byte> out;
    for (size_t i=0; i<phases(); ++i)
    {
      out.push_back(255^_mask[i][addr]);
    }
    return out;
  }

private:
  typedef vector<Bitmap> BitmapVec;

  string    _name;

  BitmapVec _bitmap;
  BitmapVec _mask;

  Bitmap    _minMask;
  Bitmap    _maxMask;
};

#endif
