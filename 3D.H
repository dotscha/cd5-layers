#ifndef ThreeD
#define ThreeD

#include <vector>
#include <cmath>

using namespace std;

struct P3D
{
  P3D(double x_=0,double y_=0,double z_=0):x(x_),y(y_),z(z_) {}

  double dist(const P3D& p) const
  {
    return sqrt((x-p.x)*(x-p.x)+(y-p.y)*(y-p.y)+(z-p.z)*(z-p.z));
  }

  double length()                 const { return dist(P3D()); }
  P3D operator*(double m)         const { return P3D(x*m,y*m,z*m); }
  P3D operator/(double d)         const { return P3D(x/d,y/d,z/d); }
  P3D operator+(const P3D& p)     const { return P3D(x+p.x,y+p.y,z+p.z); }
  P3D operator-(const P3D& p)     const { return P3D(x-p.x,y-p.y,z-p.z); }
  double operator*(const P3D& p)  const { return x*p.x+y*p.y+z*p.z; }
  P3D operator%(const P3D& p)     const { return P3D(y*p.z-z*p.y,z*p.x-x*p.z,x*p.y-y*p.x); }

  double x,y,z;
};

typedef vector<P3D> Nodes;

struct Object3D
{
  virtual bool intersect(const P3D& from, const P3D& dir, P3D& to, P3D& normal) const = 0;

  virtual ~Object3D() {}
};

struct Sphere : public Object3D
{
  Sphere(const P3D& c, double r)
  :center(c),radius(r)
  {}

  P3D center;
  double radius;

  bool intersect(const P3D& from, const P3D& dir, P3D& to, P3D& normal) const
  {
    //(from+x*dir-center)^2 = radius^2
    P3D o = from-center;
    double c = o*o - radius*radius;
    double b = o*dir*2.0;
    double a = dir*dir;
    double D = b*b-a*c*4.0;
    if (D<0)
    {
      return false;
    }
    b = -b/(2*a);
    D = sqrt(D)/(2*a);
    if (b-D>0)
    {
      to = from+dir*(b-D);
      normal = to - center;
      return true;
    }
    if (b+D>0)  //inside
    {
      to = from+dir*(b+D);
      normal = center - to;
      return true;
    }
    return false;
  }
};

struct Triangle : public Object3D
{
  Triangle(const P3D& x, const P3D& y, const P3D& z)
  :a(x),b(y),c(z)
  {}

  P3D a,b,c;

  void turn()
  {
    P3D tmp = b;
    b = c;
    c = tmp;
  }

  P3D normal() const
  {
    return (a-b)%(a-c);
  }

  bool intersect(const P3D& from, const P3D& dir, P3D& to, P3D& normal) const
  {
    //a + x*(b-a) + y*(c-a) = from + z*dir
    //a-from = x*(a-b) + y*(a-c) + z*dir
    P3D fa = a-from;
    P3D ba = a-b;
    P3D ca = a-c;
    P3D zn = ba%ca;
    double z = (fa*zn)/(dir*zn);
    if (z<=0)
    {
      return false;
    }
    P3D xn = ca%dir;
    double x = (fa*xn)/(ba*xn);
    if (x<0 || x>1)
    {
      return false;
    }
    P3D yn = ba%dir;
    double y = (fa*yn)/(ca*yn);
    if ((y<0) || (y>1) || ((x+y)>1))
    {
      return false;
    }
    to = from + dir * z;
    normal = zn;
    if ((dir*normal) > 0)
    {
      normal = normal*-1;
    }
    return true;
  }
};

typedef vector<Triangle>  Triangles;


#endif
