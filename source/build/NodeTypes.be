/*
 * Copyright (c) 2006-2023, the Bennt Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

final class Build:NodeTypes {

   create() self { }

   default() self {
      
      fields {
         Int TRANSUNIT = 1;
         Int VAR = 2;
         Int NULL = 3;
         Int CALL = 4;
         Int NAMEPATH = 5;
         Int CLASS = 6;
         Int EMIT = 8;
         Int IFEMIT = 9;
         Int TRUE = 10;
         Int FALSE = 11;
         Int BRACES = 12;
         Int RBRACES = 13;
         Int RPARENS = 14;
         Int LOOP = 15;
         Int FIELDS = 94;
         Int SLOTS = 23;
         Int ELSE = 16;
         Int FINALLY = 93;
         Int TRY = 17;
         Int CATCH = 18;
         Int IF = 19;
         Int SPACE = 20;
         Int METHOD = 21;
         Int DEFMOD = 74;
         Int PARENS = 22;
         Int FLOATL = 25;
         Int INTL = 26;
         Int DIVIDE = 27;
         Int DIVIDE_ASSIGN = 86;
         Int MULTIPLY = 28;
         Int MULTIPLY_ASSIGN = 87;
         Int STRQ = 29;
         Int WSTRQ = 30;
         Int STRINGL = 31;
         Int WSTRINGL = 33;
         Int NEWLINE = 32;
         Int ASSIGN = 35;
         Int EQUALS = 36;
         Int NOT = 37;
         Int NOT_EQUALS = 38;
         Int OR = 39;
         Int AND = 40;
         Int OR_ASSIGN = 92;
         Int AND_ASSIGN = 91;
         Int LOGICAL_OR = 89;
         Int LOGICAL_AND = 90;
         Int GREATER = 41;
         Int GREATER_EQUALS = 42;
         Int LESSER = 43;
         Int LESSER_EQUALS = 44;
         Int ADD = 45;
         Int INCREMENT = 46;
         Int ADD_ASSIGN = 47;
         Int INCREMENT_ASSIGN = 84;
         Int SUBTRACT = 48;
         Int DECREMENT = 49;
         Int SUBTRACT_ASSIGN = 83;
         Int DECREMENT_ASSIGN = 85;
         Int ID = 50;
         Int COLON = 51;
         Int WHILE = 52;
         Int FOREACH = 53;
         Int BLOCK = 72;
         Int USE = 54;
         Int AS = 55;
         Int SEMI = 56;
         Int EXPR = 57;
         Int COMMA = 58;
         Int ACCESSOR = 59;
         Int DOT = 60;
         Int BREAK = 61;
         Int IDX = 62;
         Int IDXACC = 73;
         Int RIDX = 63;
         Int TOKEN = 64;
         Int MODULUS = 65;
         Int MODULUS_ASSIGN = 88;
         Int ELIF = 66;
         Int FOR = 67;
         Int IN = 68;
         Int CONTINUE = 69;
         Int ATYPE = 71;
         Int FSLASH = 80;
      }
   }
}
