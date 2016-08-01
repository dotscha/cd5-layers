#ifndef GRAPHIC
#define GRAPHIC

#include "Bitmap.H"
#include <cstdlib>
#include <algorithm>
#include <list>

struct Graphic
{
  Graphic(Bitmap& img)
  :bitmap(img)
  {
  }

  bool peek(int x, int y) const
  {
    if (!visible(x,y))
    {
      return 0;
    }
    int addr = (y/8)*320 + (x/8)*8 + y%8;
    int bit = 128 >> (x%8);
    return bitmap[addr] & bit;
  }

  bool plot(int x, int y, bool color = 1)
  {
    if (!visible(x,y))
    {
      return 0;
    }
    int addr = (y/8)*320 + (x/8)*8 + y%8;
    int bit = 128 >> (x%8);
    bool ret = bitmap[addr] & bit;
    if (color)
    {
      bitmap[addr] |= bit;
    }
    else
    {
      bitmap[addr] &= (255^bit);
    }
    return ret;
  }

  void line(int x1, int y1, int x2, int y2, bool color = 1)
  {
    line(x1+0.5,y1+0.5,x2+0.5,y2+0.5,color);
  }

  void line(double x1, double y1, double x2, double y2, bool color = 1)
  {
    int ix1 = (int)x1, ix2 = (int)x2, iy1 = (int)y1, iy2 = (int)y2;
    int steps = max(abs(ix1-ix2),abs(iy1-iy2));
    if (steps==0)
    {
      plot((int)x1,(int)y1,color);
      return;
    }
    double x = x1, y = y1;
    double dx = (double)(x2-x1) / (double)steps;
    double dy = (double)(y2-y1) / (double)steps;
    for (int i = 0; i<=steps; ++i)
    {
      plot((int)x,(int)y,color);
      x+=dx;
      y+=dy;
    }
  }

  void bspline(
    double x0, double y0,
    double x1, double y1,
    double x2, double y2,
    double x3, double y3,
    bool color = 1,
    double max_seg = 6)
  {
    if ((x0-x3)*(x0-x3)+(y0-y3)*(y0-y3)<=max_seg*max_seg)
    {
      line(x0,y0,x3,y3,color);
    }
    else
    {
      double x4=(x0+x1)/2, y4=(y0+y1)/2;
      double x5=(x1+x2)/2, y5=(y1+y2)/2;
      double x6=(x2+x3)/2, y6=(y2+y3)/2;
      double x7=(x4+x5)/2, y7=(y4+y5)/2;
      double x8=(x5+x6)/2, y8=(y5+y6)/2;
      double x9=(x7+x8)/2, y9=(y7+y8)/2;
      bspline(x0,y0,x4,y4,x7,y7,x9,y9,color,max_seg);
      bspline(x9,y9,x8,y8,x6,y6,x3,y3,color,max_seg);
    }
  }

  void disk(double ox, double oy, double r, bool color = 1)
  {
    double rr = r*r;
    for (double x = 0.5; x<320; ++x)
    {
      for (double y = 0.5; y<200; ++y)
      {
        double dx = x-ox;
        double dy = y-oy;
        if (dx*dx+dy*dy<=rr)
        {
          plot((int)x,(int)y,color);
        }
      }
    }
  }

  void paint(int x, int y, bool color = 1)
  {
    //slow but working ...
    list<Point> que;
    que.push_back(Point(x,y));
    while(que.size())
    {
      Point p = que.front();
      que.pop_front();
      x = p.x;
      y = p.y;
      if (peek(x,y)!=color)
      {
        plot(x,y,color);
        if (visible(x+1,y) && peek(x+1,y)!=color) que.push_back(Point(x+1,y));
        if (visible(x-1,y) && peek(x-1,y)!=color) que.push_back(Point(x-1,y));
        if (visible(x,y+1) && peek(x,y+1)!=color) que.push_back(Point(x,y+1));
        if (visible(x,y-1) && peek(x,y-1)!=color) que.push_back(Point(x,y-1));
      }
    }
  }

  void dilate()
  {
    Bitmap copy = bitmap;
    Graphic g(copy);
    for (int x = 0; x<320; ++x)
    {
      for (int y = 0; y<200; ++y)
      {
        plot(x,y,g.peek(x,y)||g.peek(x+1,y)||g.peek(x-1,y)||g.peek(x,y+1)||g.peek(x,y-1));
      }
    }
  }

private:

  struct Point
  {
    Point(int x_,int y_):x(x_),y(y_){}
    int x,y;
  };

  static bool visible(int x, int y)
  {
    return 0<=x && x<320 && 0<=y && y<200;
  }

  Bitmap& bitmap;
};

#endif //GRAPHIC
