
First - quick Getting Started for Development! (more about Abelii below...)

First, install git for your platform (if not already done)

Debian et all Linux:
(run at command line)
sudo apt-get install git git-gui

Macos:
First install brew if you don't have it - https://brew.sh/
(run at command line)
brew install git 

Windows:
(download and install)
https://git-scm.com/download/win

(the rest of the instructions assume running in terminal after performing the above
  on windows this means opening the shell installed when git-scm installed)
  
create and enter a working directory of your choosing (cd $HOME;mkdir Workspace - possibly)
git clone https://gitlab.com/bitsii/abelii.git
cd abelii
./scripts/devprep.sh

devprep will install some more things / tell you to install some more things
(those things are jdk11, node.js, mono)
and then tell you to run the initial build to bootstrap your environment

End of Getting Started for Development!

Abelii is a general purpose, object oriented programming language with an emphasis on simplicity and practicality, with a translator and base library licensed under the [BSD-3-Clause](https://opensource.org/licenses/BSD-3-Clause) open source license.  It is implemented as a self-hosted source-to-source translator targeting C#/.Net, Java, and JavaScript.  The language takes inspiration from Python, Perl, Java, C#, and C++.  One of the features is to be able to write core code once and use it in a hybrid application targeting the major platforms - a Linux, Windows, or Mac application, a hosted application as a website, and Android and IOS mobile applications ( see [abeliiApp](https://gitlab.com/bitsii/abeliiApp) ).

The language borrows automatic memory management via garbage collection from it's host runtimes and supports both statically and dynamically typed variables (is "gradually typed" ).  All function calls are methods and all values are references to instances of classes.  Single-Parent inheritance is supported and all classes derive from a base class System:Object.  Operator overloading is supported (operations are translated to method call names by convention).  There is also built - in support for accessors, default accessors are created for all member variables but can be overriden to modify their behavior (and "virtual" members can be created simply by implementing properly named methods).  try/catch exception handling syntax is supported.  All variables are either member variables (accomplished by enclosing their declaration in a fields { } block) or method-scope local variables (ala Python).  Support for global state is available through a built in singleton behavior activated by implementing a default() { } method for a class and there is also a static, single-assignment mechanism ( only performed the first time the given code is execute, =@ ).

An example: 

```
class Hi {

   main() {
      "Yo".print();
   }

}
```


If "Hi" is the "main" class defined at compile time that's it - you'll get a "Yo" back - as the defined entry class has an instance constructed and it's main method called for the program entry point at startup.  You can also call this from other code you might write in the following way:

```
use Hi;

/*...*/

Hi.main();
```

(Arguments from the command line can be retrieved from environment classes available in the base library - optional command line parsing for dash-notation parameters, etc, is available in the base library as well).

A simple base library includes mutable String and Int(eger) implementations as well as (Hash)Map, Set, List (Array), LinkedList, Stack and more.  Basic file and stream manipulation and input/output is also available.  The language has some support for multi-threading including reentrant locks (where available - C#/Java - Javascript has IOS App support for concurrently executing runtimes).  Abelii also supports dynamic invocation and introspection and provides many functional programming capabilities in an object oriented way.  

**Where to go next:**

[Show me the code](https://gitlab.com/bitsii/abelii)

[Need some help...](https://stackoverflow.com/questions/tagged/abelii)

[Houston, we have a problem](https://gitlab.com/bitsii/abelii/issues)

