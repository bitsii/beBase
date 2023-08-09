// Copyright 2006 The Bennt Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Container:Map;

final class Build:Constants {
    
    new(build) self {
    
      fields {
      
         Text:Tokenizer twtok;
         Map matchMap;
         Map rwords;
         
         Int maxargs = 16;
         Int extraSlots = 2;
         //padding before mtdx values, will be sufficient to cover the
         //rest of cldef when mtdx entries are tacked on to the end.
         Int mtdxPad = 26; 
         Build:NodeTypes ntypes = Build:NodeTypes.new();
         Map unwindTo = Map.new();
         Map unwindOk = Map.new();
         Map oper = Map.new();
         Map operNames = Map.new();
         Map conTypes = Map.new();
         Map parensReq = Map.new();
         Map anchorTypes = Map.new();
      
      }
      
      unwindTo.put("braces", true);
      
      unwindOk.put("call", true);
      unwindOk.put("accessor", true);
      unwindOk.put("parens", true);
      
      oper.put(ntypes.NOT, 0);
      oper.put(ntypes.INCREMENT, 0);
      oper.put(ntypes.DECREMENT, 0);
      oper.put(ntypes.INCREMENT_ASSIGN, 0);
      oper.put(ntypes.DECREMENT_ASSIGN, 0);
      oper.put(ntypes.MULTIPLY, 1);
      oper.put(ntypes.DIVIDE, 1);
      oper.put(ntypes.MODULUS, 1);
      oper.put(ntypes.ADD, 2);
      oper.put(ntypes.SUBTRACT, 2);
      oper.put(ntypes.GREATER, 3);
      oper.put(ntypes.GREATER_EQUALS, 3);
      oper.put(ntypes.LESSER, 3);
      oper.put(ntypes.LESSER_EQUALS, 3);
      oper.put(ntypes.EQUALS, 4);
      oper.put(ntypes.NOT_EQUALS, 4);
      oper.put(ntypes.AND, 5);
      oper.put(ntypes.OR, 6);
      oper.put(ntypes.LOGICAL_AND, 5);
      oper.put(ntypes.LOGICAL_OR, 6);
      oper.put(ntypes.IN, 7);
      oper.put(ntypes.ADD_ASSIGN, 8);
      oper.put(ntypes.SUBTRACT_ASSIGN, 8);
      oper.put(ntypes.MULTIPLY_ASSIGN, 8);
      oper.put(ntypes.DIVIDE_ASSIGN, 8);
      oper.put(ntypes.MODULUS_ASSIGN, 8);
      oper.put(ntypes.AND_ASSIGN, 8);
      oper.put(ntypes.OR_ASSIGN, 8);
      oper.put(ntypes.ASSIGN, 9);
      
      operNames.put(ntypes.NOT, "NOT");
      operNames.put(ntypes.INCREMENT, "INCREMENT");
      operNames.put(ntypes.DECREMENT, "DECREMENT");
      operNames.put(ntypes.MULTIPLY, "MULTIPLY");
      operNames.put(ntypes.DIVIDE, "DIVIDE");
      operNames.put(ntypes.MODULUS, "MODULUS");
      operNames.put(ntypes.ADD, "ADD");
      operNames.put(ntypes.SUBTRACT, "SUBTRACT");
      operNames.put(ntypes.GREATER, "GREATER");
      operNames.put(ntypes.GREATER_EQUALS, "GREATER_EQUALS");
      operNames.put(ntypes.LESSER, "LESSER");
      operNames.put(ntypes.LESSER_EQUALS, "LESSER_EQUALS");
      operNames.put(ntypes.EQUALS, "EQUALS");
      operNames.put(ntypes.NOT_EQUALS, "NOT_EQUALS");
      operNames.put(ntypes.AND, "AND");
      operNames.put(ntypes.OR, "OR");
      operNames.put(ntypes.LOGICAL_AND, "LOGICAL_AND");
      operNames.put(ntypes.LOGICAL_OR, "LOGICAL_OR");
      operNames.put(ntypes.IN, "IN");
      operNames.put(ntypes.ADD_ASSIGN, "ADD_VALUE");
      operNames.put(ntypes.SUBTRACT_ASSIGN, "SUBTRACT_VALUE");
      operNames.put(ntypes.INCREMENT_ASSIGN, "INCREMENT_VALUE");
      operNames.put(ntypes.DECREMENT_ASSIGN, "DECREMENT_VALUE");
      operNames.put(ntypes.MULTIPLY_ASSIGN, "MULTIPLY_VALUE");
      operNames.put(ntypes.DIVIDE_ASSIGN, "DIVIDE_VALUE");
      operNames.put(ntypes.MODULUS_ASSIGN, "MODULUS_VALUE");
      operNames.put(ntypes.AND_ASSIGN, "AND_VALUE");
      operNames.put(ntypes.OR_ASSIGN, "OR_VALUE");
      operNames.put(ntypes.ASSIGN, "ASSIGN");
      
      conTypes.put(ntypes.IF, true);
      conTypes.put(ntypes.ELIF, true);
      conTypes.put(ntypes.WHILE, true);
      conTypes.put(ntypes.FOR, true);
      conTypes.put(ntypes.FOREACH, true);
      conTypes.put(ntypes.EMIT, true);
      conTypes.put(ntypes.IFEMIT, true);
      conTypes.put(ntypes.METHOD, true);
      conTypes.put(ntypes.CLASS, true);
      conTypes.put(ntypes.EXPR, true);
      conTypes.put(ntypes.ELSE, true);
      conTypes.put(ntypes.FINALLY, true);
      conTypes.put(ntypes.TRY, true);
      conTypes.put(ntypes.LOOP, true);
      conTypes.put(ntypes.FIELDS, true);
      conTypes.put(ntypes.SLOTS, true);
      conTypes.put(ntypes.CATCH, true);
      conTypes.put(ntypes.TRANSUNIT, true);
      conTypes.put(ntypes.BRACES, true);
      conTypes.put(ntypes.PARENS, true);
      conTypes.put(ntypes.IDX, true);
      
      parensReq.put(ntypes.IF, true);
      parensReq.put(ntypes.ELIF, true);
      parensReq.put(ntypes.WHILE, true);
      parensReq.put(ntypes.FOR, true);
      parensReq.put(ntypes.FOREACH, true);
      parensReq.put(ntypes.EMIT, true);
      parensReq.put(ntypes.IFEMIT, true);
      parensReq.put(ntypes.METHOD, true);
      parensReq.put(ntypes.CATCH, true);
      
      anchorTypes.put(ntypes.IF, true);
      anchorTypes.put(ntypes.ELIF, true);
      anchorTypes.put(ntypes.WHILE, true);
      anchorTypes.put(ntypes.FOR, true);
      anchorTypes.put(ntypes.FOREACH, true);
      anchorTypes.put(ntypes.EXPR, true);
      
      prepare();
      
    }
    
    prepare() {
   
      matchMap = Map.new();
      any space = " ";
      
      any ntok = "/";
      twtok = Text:Tokenizer.new(ntok, true);
      matchMap.put(ntok, ntypes.DIVIDE);
      
      ntok = "{";
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.BRACES);
      
      ntok = "}";
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.RBRACES);
      
      ntok = "(";
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.PARENS);
      
      ntok = ")";
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.RPARENS);
      
      ntok = ";";
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.SEMI);
      
      ntok = ":";
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.COLON);
      
      ntok = ",";
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.COMMA);
      
      ntok = "+";
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.ADD);
      
      ntok = "";
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.ATYPE);
      
      ntok = "-";
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.SUBTRACT);
      
      //must do fromCode: dblquote pcent equals gtr lsr not amper star period fslash
      
      ntok = String.codeNew(92); //fslash
      
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.FSLASH);
      
      ntok = String.codeNew(34); //dblquote
      
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.STRQ);
      
      ntok = String.codeNew(39); //sglquote
      
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.WSTRQ);
      
      ntok = String.codeNew(91); //[
      
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.IDX);
      
      ntok = String.codeNew(93); //]
      
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.RIDX);
      
      ntok = String.codeNew(37); //pcent //was some problem here
      
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.MODULUS);
      
      ntok = String.codeNew(61); //equals
      
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.ASSIGN);
      
      ntok = String.codeNew(62); //gtr
      
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.GREATER);
      
      ntok = String.codeNew(60); //lsr
      
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.LESSER);
      
      ntok = String.codeNew(33); //not
      
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.NOT);
      
      ntok = String.codeNew(38); //amper
      
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.AND);
      
      ntok = String.codeNew(124); //pipe - or
      
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.OR);
      
      ntok = String.codeNew(42); //star
      
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.MULTIPLY);
      
      ntok = String.codeNew(46); //period
      
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.DOT);
      
      ntok = String.codeNew(32); //space
      
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.SPACE);
      
      ntok = String.codeNew(9); //tab
      
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.SPACE);
      
      ntok = Text:Strings.new().cr;
      
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.NEWLINE);
      
      ntok = Text:Strings.new().lf;
      
      twtok.addToken(ntok);
      matchMap.put(ntok, ntypes.NEWLINE);
      
      
      rwords = Map.new();
      rwords.put("use", ntypes.USE);
      rwords.put("as", ntypes.AS);
      rwords.put("class", ntypes.CLASS);
      rwords.put("method", ntypes.METHOD);
      rwords.put("final", ntypes.DEFMOD);
      rwords.put("local", ntypes.DEFMOD);
      rwords.put("notNull", ntypes.DEFMOD);
      rwords.put("any", ntypes.VAR);
      rwords.put("auto", ntypes.VAR);
      rwords.put("if", ntypes.IF);
      rwords.put("unless", ntypes.IF);
      rwords.put("elseIf", ntypes.ELIF);
      rwords.put("else", ntypes.ELSE);
      rwords.put("finally", ntypes.FINALLY);
      rwords.put("loop", ntypes.LOOP);
      rwords.put("fields", ntypes.FIELDS);
      rwords.put("slots", ntypes.SLOTS);
      rwords.put("while", ntypes.WHILE);
      rwords.put("until", ntypes.WHILE);
      rwords.put("for", ntypes.FOR);
      rwords.put("in", ntypes.IN);
      rwords.put("emit", ntypes.EMIT);
      rwords.put("ifEmit", ntypes.IFEMIT);
      rwords.put("ifNotEmit", ntypes.IFEMIT);
      rwords.put("break", ntypes.BREAK);
      rwords.put("continue", ntypes.CONTINUE);
      rwords.put("null", ntypes.NULL);
      rwords.put("true", ntypes.TRUE);
      rwords.put("false", ntypes.FALSE);
      rwords.put("try", ntypes.TRY);
      rwords.put("catch", ntypes.CATCH);
   }
}

