
# Brace

<br />
<!--<div align="center">
  <a href="https://github.com/github_username/repo_name">
    <img src="images/beysant.jpg" alt="Logo" width="80" height="80">
  </a>
  </div>-->

Brace is a general purpose object oriented programming language with an emphasis on simplicity and practicality.  There is an implementation as a self-hosted source-to-source translator targeting Java, C++, JavaScript, and C#/.Net with a standard base library, all licensed under the [BSD-2-Clause](https://opensource.org/licenses/BSD-2-Clause) open source license.  The language takes inspiration from Perl, Java, and Python.  One of the features is to be able to write core code once and use it in a hybrid application targeting the major platforms - Linux, Windows, or Mac desktop application, an IOS or Android app, or a hosted application as a website - see [beApp](https://gitlab.com/bitsii/beApp).  There is also support for Arduino (especially esp8266) via C++ - see [beEmb](https://github.com/bitsii/beEmb).

The language borrows automatic memory management via garbage collection from it's host runtimes (usually - C++ has a custom collector, the SGC) and supports both statically and dynamically typed variables (is "gradually typed" ).  Everything is an object, including primitive data types.  Single-Parent inheritance is supported and all classes derive from a base class System:Object.  Operator overloading is supported via method naming conventions and operator expression are translated to method calls.  There is also built - in support for accessors, default accessors are created for all "field" member variables but can be overriden to modify their behavior (and "virtual" members can be created simply by implementing properly named methods).  "slot" member variables do not have auto-generated accessors.  try/catch exception handling syntax is supported.  All variables must be declared and are either member variables (declared in field or slot scopes) or method-scope local variables (ala Python).  Support for global state is only available through a built in singleton behavior activated by implementing a default() { } method for a class.

Quick Getting Started for Development!

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
  on windows this means opening the shell installed with git-scm, not the standard windows command prompt)
  
create and enter a working directory of your choosing (cd $HOME;mkdir Workspace - possibly)
git clone https://github.com/bitsii/beBase
cd beBase
./scripts/devprepjv.sh

devprep will install some more things / tell you to install some more things
(those things are java)
and then tell you to run the initial build to bootstrap your environment

The above sets up the basic environment for Brace to emit Java and compile / run with the jdk (the default).  This is all you
need for the Brace runtime for beApp (web, android, ios) and beEmb (embedded/esp) (it can generate any of the target languages, js, c++, java, c#, etc)

Brace also emits and self hosts in other languages.  If you want you can also use javascript (nodejs, browser).  You don't need to install anything more to support using beApps with Brace in the browser, but if you want to develop with the self hosted compiler running with javascript you can (after the base setup is done) run

./scripts/devprepjs.sh

for that.  

C# is also supported, run 

./scripts/devprepcs.sh

for that.

C++ is as well, but really only for embedded development.  More info in the beEmb

End of Getting Started for Development!

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

A simple base library includes mutable String and Int(eger) implementations as well as (Hash)Map, Set, List (Array), LinkedList, Stack and more.  Basic file and stream manipulation and input/output is also available.  The language has some support for multi-threading including reentrant locks (where available - C#/Java - Javascript has IOS App support for concurrently executing runtimes).  Brace also supports dynamic invocation and introspection and provides many functional programming capabilities in an object oriented way.

**Where to go next:**

[Show me the code](https://github.com/bitsii/beBase)

[Need some help...](https://stackoverflow.com/questions/tagged/Brace)

[Houston, we have a problem](https://github.com/bitsii/beBase/issues)


The official list of Brace Authors:

Craig Welch <bitsiiway@gmail.com>
