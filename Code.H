#ifndef CODE
#define CODE

#include <map>
#include <vector>
#include <string>

struct Command
{
  Command(string ty, string par = "", string sel = ""):type(ty),param(par),selector(sel) {}

  string type;
  string param;
  string selector;

  string print() const
  {
    return options[selector];
  }

protected:

  mutable map<string,string> options;
};

typedef vector<Command> Code;

/**
 * Command initializers
 */

struct lda_byte : Command
{
  lda_byte(string d)
  :Command("a",d)
  {
    options[""] = "lda #"+param;
  }
};

struct ora_byte : Command
{
  ora_byte(string d)
  :Command("a",d)
  {
    options[""] = (param=="0" ? ";ora #" : "ora #")+param;
  }
};

struct and_byte : Command
{
  and_byte(string d)
  :Command("a",d)
  {
    options[""] = (param=="255" ? ";and #" : "and #")+param;
  }
};

struct ldi_addr : Command
{
  ldi_addr(string a)
  :Command("i",a,"x")
  {
    options["x"] = "ldx "+param;
    options["y"] = "ldy "+param;
    options["sx"] = ";ldx "+param; //skip, it's already in X
    options["sy"] = ";ldy "+param; //skip, it's already in Y
  }
};

struct lda_addr_i : Command
{
  lda_addr_i(string a)
  :Command("a_i",a,"x")
  {
    options["x"] = "lda "+param+",x";
    options["y"] = "lda "+param+",y";
  }
};

struct ora_addr_i : Command
{
  ora_addr_i(string a)
  :Command("a_i",a,"x")
  {
    options["x"] = "ora "+param+",x";
    options["y"] = "ora "+param+",y";
  }
};

struct and_addr_i : Command
{
  and_addr_i(string a)
  :Command("a_i",a,"x")
  {
    options["x"] = "and "+param+",x";
    options["y"] = "and "+param+",y";
  }
};

struct sta_addr : Command
{
  sta_addr(string a)
  :Command("wa",a)
  {
    options[""] = "sta "+param;
  }
};

#endif
