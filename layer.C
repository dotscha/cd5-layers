#include "Graphic.H"
#include "Scene.H"
#include "3D.H"
#include <iostream>
#include <fstream>
#include <cmath>
#include <cstdlib>
#include <set>

using namespace std;

const double PI = 104348.0/33215.0;

double r_light = 0.05;
P3D light[320*200];
P3D eye(0,0,9);
double screen = 200;

size_t LATI1 = 13;
size_t LONG1 = 30;
size_t LATI2 = 128;
size_t LONG2 = 128;

Sphere ball = Sphere(eye,eye.z*30/screen);

fstream out;

Bitmap icos_out;
Bitmap icos_in;

Bitmap ball_light;
Bitmap ball_dark;

template <typename N>
static string num(const N& n)
{
  stringstream ss (stringstream::out);
  ss << (long)n;
  return ss.str();
}


Nodes calcNodes()
{
  double phi = (sqrt(5.0)+1)/2;
  Nodes nodes;
  /*
  nodes.push_back(P3D(0, +1, +phi));
  nodes.push_back(P3D(0, -1, +phi));
  nodes.push_back(P3D(0, +1, -phi));
  nodes.push_back(P3D(0, -1, -phi));
  nodes.push_back(P3D(+1, +phi, 0));
  nodes.push_back(P3D(-1, +phi, 0));
  nodes.push_back(P3D(+1, -phi, 0));
  nodes.push_back(P3D(-1, -phi, 0));
  nodes.push_back(P3D(+phi, 0, +1));
  nodes.push_back(P3D(+phi, 0, -1));
  nodes.push_back(P3D(-phi, 0, +1));
  nodes.push_back(P3D(-phi, 0, -1));
  */
  nodes.push_back(P3D(-phi, 0, +1));
  nodes.push_back(P3D(-phi, 0, -1));
  nodes.push_back(P3D(-1, +phi, 0));
  nodes.push_back(P3D(-1, -phi, 0));
  nodes.push_back(P3D(0, +1, +phi));
  nodes.push_back(P3D(0, -1, +phi));
  nodes.push_back(P3D(0, +1, -phi));
  nodes.push_back(P3D(0, -1, -phi));
  nodes.push_back(P3D(+1, +phi, 0));
  nodes.push_back(P3D(+1, -phi, 0));
  nodes.push_back(P3D(+phi, 0, +1));
  nodes.push_back(P3D(+phi, 0, -1));
  return nodes;
}

void rotate(double& x, double& y, double ang)
{
  ang *= PI/180;
  double xx = x*cos(ang) + y*sin(ang);
  y = y*cos(ang) - x*sin(ang);
  x = xx;
}

P3D smiddle(const P3D& p1, const P3D& p2, double w = 0.5)
{
  P3D m = p1*(1-w) + p2*w;
  m = m*(p1.length()/m.length());
  return m;
}

P3D transform(P3D p)
{
  rotate(p.y,p.z,10);
  rotate(p.x,p.z,25);
  return p + eye;
}

P3D project(P3D p)
{
  p.x *= screen/p.z;
  p.y *= screen/p.z;
  p.x += 160;
  p.y += 100;

  return p;
}

void zoom(Triangle& t, double m)
{
  P3D o = (t.a+t.b+t.c)/3.0;
  t.a = o + (t.a-o)*m;
  t.b = o + (t.b-o)*m;
  t.c = o + (t.c-o)*m;
}

Bitmap calcShadow(const Triangle& t, double& z)
{
  z = 0;
  Bitmap img;
  Graphic g(img);
  P3D camera;
  P3D dir(0,0,screen);
  P3D to,norm;
  P3D tmp1,tmp2;
  int z_count = 0;
  for (int x = 0 ; x<320; ++x)
  {
    dir.x = (x-159.5);
    for (int y = 0 ; y<200; ++y)
    {
      P3D& up = light[x+y*320];
      dir.y = (y-99.5);
      if (ball.intersect(camera,dir,to,norm))
      {
        if ((up*norm>0) && t.intersect(to,up,tmp1,tmp2))
        {
          g.plot(x,y);
          z+=to.z;
          z_count++;
        }
      }
    }
  }
  z/=z_count;
  return img;
}

static int obj_count = 0;

void addTriangle(Scene& s, Triangle tri)
{
  tri.a = transform(tri.a);
  tri.b = transform(tri.b);
  tri.c = transform(tri.c);
  bool face;
  {
    P3D mid = (tri.a+tri.b+tri.c)/3;
    P3D nor = mid-eye;
    face = nor*mid < 0;
  }
  out << "obj" << obj_count << "_phase = obj_phases+" << obj_count << endl;
  BitmapObject obj("obj"+num(obj_count));
  BitmapObject sh_obj("obj"+num(obj_count));
  double zShadow = 0;
  cout << "object: " << obj.name() << endl;
  obj_count++;
  for (int p = 0; p<8; ++p)
  {
    Bitmap img;
    if (p)
    {
      Graphic g(img);
      Triangle t = tri;
      zoom(t,p/7.0);
      P3D n1 = project(t.a);
      P3D n2 = project(t.b);
      P3D n3 = project(t.c);
      g.line(n1.x,n1.y,n2.x,n2.y);
      g.line(n2.x,n2.y,n3.x,n3.y);
      g.line(n3.x,n3.y,n1.x,n1.y);
      Bitmap msk = img;
      Graphic(msk).paint(0,0);
      msk= !(msk^img);
      if (!face)
      {
        img|=(msk&icos_in);
      }
      else
      {
        img|=(msk&icos_out);
      }
      
      double z;
      //shadow
      /*
      Bitmap shadow = calcShadow(t,z);
      img|=(!msk)&shadow;
      msk|=shadow;
      */
      obj.addPhase(img,msk);
      
      /**/
      Bitmap shadow = calcShadow(t,z);
      if (z!=0)
      {
        zShadow = z;
      }
      shadow= (!msk)&shadow;
      sh_obj.addPhase(shadow&ball_dark,shadow&ball_dark);
      /**/
    }
    else
    {
      obj.addPhase(img,img);
      sh_obj.addPhase(img,img);
    }
  }
  s.addBitmapObject(10000-(int)(100*(tri.a.z+tri.b.z+tri.c.z)),obj);
  if (zShadow!=0)
  {
    s.addBitmapObject(10000-(int)(300*zShadow),sh_obj);
  }
}


void addTriangles(Scene& scene, const Triangles& ts)
{
  for (size_t i = 0; i<ts.size(); ++i)
  {
    addTriangle(scene,ts[i]);
  }
}

Triangles calcTriangles(const Nodes& nodes)
{
  Triangles ts;
  size_t s = nodes.size();
  for (size_t i = 0; i<s; ++i)
  {
    for (size_t j = i+1; j<s; ++j)
    {
      for (size_t k = j+1; k<s; ++k)
      {
        if (nodes[i].dist(nodes[j])<2.01 && nodes[j].dist(nodes[k])<2.01 && nodes[k].dist(nodes[i])<2.01)
        {
          cout << "triangle " << i << " " << j << " " << k << endl;

          P3D p1 = nodes[i];
          P3D p2 = nodes[j];
          P3D p3 = nodes[k];
          //4 triangles
          /**
          P3D p12 = smiddle(p1,p2);
          P3D p13 = smiddle(p1,p3);
          P3D p23 = smiddle(p2,p3);
          ts.push_back(Triangle(p1,p12,p13));
          ts.push_back(Triangle(p2,p12,p23));
          ts.push_back(Triangle(p3,p13,p23));
          ts.push_back(Triangle(p12,p13,p23));
          /**/
          //9 triangles
          /**/
          P3D p112 = smiddle(p1,p2,1.0/3);
          P3D p122 = smiddle(p1,p2,2.0/3);
          P3D p113 = smiddle(p1,p3,1.0/3);
          P3D p133 = smiddle(p1,p3,2.0/3);
          P3D p223 = smiddle(p2,p3,1.0/3);
          P3D p233 = smiddle(p2,p3,2.0/3);
          P3D p123 = smiddle(p112,p233);

          ts.push_back(Triangle(p1,p112,p113));
          ts.push_back(Triangle(p2,p122,p223));
          ts.push_back(Triangle(p3,p133,p233));

          ts.push_back(Triangle(p112,p122,p123));
          ts.push_back(Triangle(p223,p122,p123));
          ts.push_back(Triangle(p223,p233,p123));
          ts.push_back(Triangle(p133,p233,p123));
          ts.push_back(Triangle(p133,p113,p123));
          ts.push_back(Triangle(p112,p113,p123));
          /**/
        }
      }
    }
  }
  return ts;
}

void otherStuff(Scene& scene)
{
  Bitmap img;
  Graphic g(img);
  /*
  g.disk(160,100,30);
  */
  P3D camera;
  P3D tmp1,tmp2;
  for (int x = 0 ; x<320; ++x)
  {
    for (int y = 0 ; y<200; ++y)
    {
      P3D dir((x-159.5),(y-99.5),screen);
      if (ball.intersect(camera,dir,tmp1,tmp2))
      {
        g.plot(x,y);
      }
    }
  }
  Bitmap msk = img;
  {
    img = ball_light;
    /**
    Bitmap tmp = !img;
    Graphic(tmp).dilate();
    img&=tmp;
    /**/
  }
  BitmapObject o("ball");
  o.addPhase(img,msk);
  scene.addBitmapObject((int)(10000-100*3*eye.z),o);
}

P3D normVec;

bool compTri(const Triangle& t1, const Triangle& t2)
{
  return 0<(normVec*(t1.a+t1.b+t1.c-t2.a-t2.b-t2.c));
}

void initBitmaps()
{
  icos_out.loadBMP("icos_out.bmp");
  vector<byte> p;
  p.push_back(85);
  p.push_back(255);
  p.push_back(2*85);
  p.push_back(255);
  icos_in.fill(p);
  ball_light.loadBMP("ball.bmp");
  ball_dark.loadBMP("ball_dark.bmp");
}

void initLight()
{
	for (size_t i = 0; i<320*200; ++i)
	{
    double ang = ((double)rand())/RAND_MAX;
    double rad = ((double)rand())/RAND_MAX;
    if (rad<=ang)
    {
      ang = 1-ang;
      rad = 1-rad;
    }
    ang = ang/rad*2*PI;
    P3D l(sin(ang)*r_light, -1 , cos(ang)*r_light);
    rotate(l.y,l.z,-27);
    light[i] = l;
	}
}

void genCode()
{
  out.open("layers.asm",ios_base::out);
  initBitmaps();
  initLight();
  Scene scene;
  Nodes nodes = calcNodes();
  Triangles ts = calcTriangles(nodes);
  normVec = nodes[0];
  sort(ts.begin(),ts.end(),compTri);
  addTriangles(scene,ts);
  otherStuff(scene);
  //calcTables(ts);
  scene.preview(0,"scene_phase0");
  scene.preview(1,"scene_phase1");
  scene.preview(2,"scene_phase2");
  scene.preview(3,"scene_phase3");
  scene.preview(4,"scene_phase4");
  scene.preview(5,"scene_phase5");
  scene.preview(6,"scene_phase6");
  scene.preview(7,"scene_phase7");
  scene.compile();
  out << "object_count = " << obj_count << endl;
  out.close();
}

Nodes calcCoords(int lati, int longi, bool rot = false)
{
  Nodes coords;
  for (int i = 0; i<lati; ++i)
  {
    double zc = (i+0.5)/lati*2-1;//cos(PI*(i+0.5)/ANG1);
    double zs = sqrt(1-zc*zc);//sin(PI*(i+0.5)/ANG1);
    for (int j = 0; j<longi; ++j)
    {
      double x = sin(2*PI*(j+0.5)/longi);
      double y = cos(2*PI*(j+0.5)/longi);
      if (rot)
      {
        coords.push_back(P3D(zc,-x*zs,y*zs));
      }
      else
      {
        coords.push_back(P3D(x*zs,zc,y*zs));
      }
    }
  }
  return coords;
}

size_t getCoord(const P3D& p, const Nodes& coords, double* error = 0)
{
  double best = p.dist(coords[0]);
  size_t best_i = 0;
  for (size_t i = 1; i<coords.size(); ++i)
  {
    double d = p.dist(coords[i]);
    if (d<best)
    {
      best = d;
      best_i = i;
    }
  }
  if (error)
  {
    *error = best;
  }
  return best_i;
}

vector<size_t> getCoords(const Nodes& nodes, const Nodes& coords, map<size_t,int>* count = 0, vector<double>* error = 0)
{
  vector<size_t> out;
  for (size_t i = 0; i<nodes.size(); ++i)
  {
    double e;
    size_t c = getCoord(nodes[i],coords,&e);
    out.push_back(c);
    if (count)
    {
      (*count)[c]++;
    }
    if (error)
    {
      error->push_back(e);
    }
  }
  return out;
}

void coordinates()
{
  Nodes coords = calcCoords(LATI1,LONG1);
  {
    out.open("obj_coords.asm",ios_base::out);
    out << "LATI1=" << LATI1 << endl;
    out << "LONG1=" << LONG1 << endl;

    Nodes nodes = calcNodes();
    Triangles ts = calcTriangles(nodes);
    Nodes mids;
    for (size_t i = 0; i<ts.size(); ++i)
    {
      P3D mid = ts[i].a + ts[i].b + ts[i].c;
      mid = mid / mid.length();
      mids.push_back(mid);
    }
    map<size_t,int> count;
    vector<size_t> midCoords = getCoords(mids,coords,&count);
    cout << "used: "<< count.size() << endl;
    cout << "coords: "<< coords.size() << endl;
    cout << "duplicates:" << endl;
    
    for (int i = 0; i<count.size(); ++i)
    {
      if (count[i]>1) cout << i << " count: " << count[i] << endl;
    }
    out << "obj_latitudes:" << endl;
    for (size_t i = 0; i<mids.size(); ++i)
    {
      out << "\t.byt " << midCoords[i]/LONG1 << endl;
    }
    out << "obj_longitudes:" << endl;
    for (size_t i = 0; i<mids.size(); ++i)
    {
      out << "\t.byt " << midCoords[i]%LONG1 << endl;
    }
    out.close();
  }
  {
    out.open("coord_map.asm",ios_base::out);
    out << "LATI2=" << LATI2 << endl;
    out << "LONG2=" << LONG2 << endl;
    Nodes coords2 = calcCoords(LATI2,LONG2,true);
    map<size_t,int> count;
    vector<size_t> coordMap = getCoords(coords,coords2,&count);
    cout << "coord trafo %: " << (double)count.size()/coords.size() << endl;
    out << "coord_latitudes:" << endl;
    for (size_t i = 0; i<LATI1; ++i)
    {
      out << "\t.byt ";
      for (size_t j = 0; j<LONG1; ++j)
      {
        if (j) out << ",";
        out << coordMap[i*LONG1+j]/LONG2;
      }
      out << endl;
    }
    out << "coord_longitudes:" << endl;
    for (size_t i = 0; i<LATI1; ++i)
    {
      out << "\t.byt ";
      for (size_t j = 0; j<LONG1; ++j)
      {
        if (j) out << ",";
        out << coordMap[i*LONG1+j]%LONG2;
      }
      out << endl;
    }
    out.close();
  }

  
}

int main(int argc, char** argv)
{
  if (argc>1)
  {
    string arg = argv[1];
    if (arg == "code")
    {
      genCode();
    }
    if (arg == "coords")
    {
      coordinates();
    }
  }
}
