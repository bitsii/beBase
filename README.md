Brace is a general purpose, object oriented programming language with an emphasis on simplicity and practicality, with a translator and base library licensed under the [MIT](https://opensource.org/licenses/MIT) open source license.  It is implemented as a self-hosted source-to-source translator targeting C#/.Net, Java, and JavaScript.  The language takes inspiration from Python and Perl as well as Java/C#/D/Smalltalk/Eiffel and others.  One of the goals is to be able to write core code once and use it in a hybrid application targeting the major platforms - a Linux, Windows, or Mac application, a hosted application as a website, and Android IOS mobile applications (see [braceApp](https://gitlab.com/abelii/abeliiapp).

The language borrows automatic memory management via garbage collection from it's host runtimes and supports both statically and dynamically typed variables.  There are no function calls which are not methods and no values which are not references to instances of classes.  Single-Parent inheritance is supported and all classes derive from a base class System:Object.  Operator overloading is supported (operations are translated to method call names by convention).  There is also built - in support for accessors, default accessors are created for all member variables but can be overriden to modify their behavior (and "virtual" members can be created simply by implementing properly named methods).  try/catch exception handling syntax is supported.  All variables are either member variables (accomplished by enclosing their declaration in a fields { } block) or method-scope local variables (ala Python).  

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

A simple base library includes mutable String and Int(eger) implementations as well as (Hash)Map, Set, List (Array), LinkedList, Stack and more.  Basic file and stream manipulation and input/output is also available.  The language has some support for multi-threading including reentrant locks (where available - C#/Java - Javascript has IOS App support for conurrently executing runtimes).  Brace also supports a rich set of reflection operations and provides some functional programming capabilities in an object oriented way.  

**Where to go next:**

[More about the Language with Examples] (https://gitlab.com/abelii/abelii/wikis/more-information-and-examples)

[Getting started - get the code, build, run] (https://gitlab.com/abelii/abelii/wikis/getting-started)

[Show me the code] (https://gitlab.com/abelii/abelii)

[Need some help...] (https://stackoverflow.com/questions/tagged/abelii)

[Houston, we have a problem] (https://gitlab.com/abelii/abelii/issues)

[...and the authoritative version of this very page...] (https://gitlab.com/abelii/abelii/wikis/home)
