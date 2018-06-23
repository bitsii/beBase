Abelii is a general - purpose object - oriented programming language with an emphasis on simplicity and practicality.  It is implemented as a self-hosted source-to-source translator targeting C#/.Net, C++, Java, and JavaScript - which takes inspiration from Python and Perl as well as Java/C#/Objc/C/C++/D/Smalltalk/Eiffel/and many others.  One of the goals is to be able to write core code once and use it in a hybrid application targeting the major environments - a Linux, Windows, or Mac application as well as Andriod and IOS mobile applications along with hosting the application as a website for access from browsers.  The translator and base library are available under the MIT License.

The language borrows automatic memory management via garbage collection from it's host runtimes and supports both statically and dynamically typed variables.  There are no function calls which are not methods and no types which are not realized as instances of classes.  Single-Parent inheritance is supported and all classes derive from a base class System:Object.  Operator overloading is supported (operations are translated to method call names by convention, in fact all operations are implemented in this way).  There is also built - in support for accessors, default accessors are created for all member variables but can be overriden to modify their behavior (and "virtual" members can be created simply by implementing properly named methods).  try/catch exception handling syntax is supported.  All variables are either member variables (accomplished by enclosing their declaration in a fields { } block) or method-scope local variables (ala Python).  

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

A simple base library includes mutable String and Int(eger) implementations as well as (Hash)Map, Set, List (array), LinkedList, Stack, collection types is provided.  Basic file and stream manipulation and input/output is also available.  The language has some support for multi-threading including reentrant locks (where available - C#/Java - although webworkers et all could be supported on Javascript).  Abe also provides some functional capabilities in an object oriented way - instances of System:Method can be instantiated for all methods and so assigned to variables or passed as arguments to methods.  

**Where to go next:**

[More about the Language with Examples] (https://gitlab.com/abelii/abelii/wikis/more-information-and-examples)

[Getting started - get the code, build, run] (https://gitlab.com/abelii/abelii/wikis/getting-started)

[Show me the code] (https://gitlab.com/abelii/abelii)

[Need some help...] (https://stackoverflow.com/questions/tagged/abelii)

[Houston, we have a problem] (https://gitlab.com/abelii/abelii/issues)

[...and the authoritative version of this very page...] (https://gitlab.com/abelii/abelii/wikis/home)
