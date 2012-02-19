// This is the official Handlebars lexer definition:
// (taken from the following revision: https://github.com/wycats/handlebars.js/blob/932e2970ad29b16d6d6874ad0bfb44b07b4cd765/src/handlebars.l)
// We base our lexer directly on that, making some modifications to account for Jison/JFlex syntax and functionality differences
// TODO there is a later commit which adds support for "escaped mustaches" here: https://github.com/wycats/handlebars.js/blob/c79c761460f7d08e3862c0c9992f65a799771851/src/handlebars.l
//
//
//%x mu
//
//%%
//
//[^\x00]*?/("{{")                 { this.begin("mu"); if (yytext) return 'CONTENT'; }
//[^\x00]+                         { return 'CONTENT'; }
//
//<mu>"{{>"                        { return 'OPEN_PARTIAL'; }
//<mu>"{{#"                        { return 'OPEN_BLOCK'; }
//<mu>"{{/"                        { return 'OPEN_ENDBLOCK'; }
//<mu>"{{^"                        { return 'OPEN_INVERSE'; }
//<mu>"{{"\s*"else"                { return 'OPEN_INVERSE'; }
//<mu>"{{{"                        { return 'OPEN_UNESCAPED'; }
//<mu>"{{&"                        { return 'OPEN_UNESCAPED'; }
//<mu>"{{!"[\s\S]*?"}}"            { yytext = yytext.substr(3,yyleng-5); this.begin("INITIAL"); return 'COMMENT'; }
//<mu>"{{"                         { return 'OPEN'; }
//
//<mu>"="                          { return 'EQUALS'; }
//<mu>"."/[} ]                     { return 'ID'; }
//<mu>".."                         { return 'ID'; }
//<mu>[\/.]                        { return 'SEP'; }
//<mu>\s+                          { /*ignore whitespace*/ }
//<mu>"}}}"                        { this.begin("INITIAL"); return 'CLOSE'; }
//<mu>"}}"                         { this.begin("INITIAL"); return 'CLOSE'; }
//<mu>'"'("\\"["]|[^"])*'"'        { yytext = yytext.substr(1,yyleng-2).replace(/\\"/g,'"'); return 'STRING'; }
//<mu>"true"/[}\s]                 { return 'BOOLEAN'; }
//<mu>"false"/[}\s]                { return 'BOOLEAN'; }
//<mu>[0-9]+/[}\s]                 { return 'INTEGER'; }
//<mu>[a-zA-Z0-9_$-]+/[=}\s\/.]    { return 'ID'; }
//<mu>\[[^\]]*\]                   { yytext = yytext.substr(1, yyleng-2); return 'ID'; }
//<mu>.                            { return 'INVALID'; }
//
//<INITIAL,mu><<EOF>>              { return 'EOF'; }

package com.dmarcotte.handlebars.parsing;

import com.intellij.lexer.FlexLexer;
import com.intellij.psi.tree.IElementType;
import com.intellij.util.containers.Stack;
import com.dmarcotte.handlebars.parsing.HbTokenTypes;

%%

%class _HbLexer
%implements FlexLexer
%final
%unicode
%function advance
%type IElementType
%eof{ return;
%eof}

%{
    private Stack<Integer> stack = new Stack<Integer>();

    public void yypushState(int newState) {
      stack.push(yystate());
      yybegin(newState);
    }

    public void yypopState() {
      yybegin(stack.pop());
    }
%}

LineTerminator = \r|\n|\r\n
SlashSmallS = \t \n\x0B\f\r
IdFollower = [=}\t\n\f\r\/.]
WhiteSpace = {LineTerminator} | [ \t\f]
AtLeast2 = "{2,}"
OpenStache = "{{"
CloseStache = "}}"
AsciiZero = [^\x00]


%state mu
%state emu

%%

<YYINITIAL> {

  [^\x00]*?"{{" {
            yypushback(2);
            yypushState(mu); if (!yytext().toString().equals("")) return HbTokenTypes.CONTENT;
        }

  [^(\{\{)\x00]+                         { return HbTokenTypes.CONTENT; }
}

<mu> {

  "{{>" { return HbTokenTypes.OPEN_PARTIAL; }
  "{{#" { return HbTokenTypes.OPEN_BLOCK; }
  "{{/" { return HbTokenTypes.OPEN_ENDBLOCK; }
  "{{^" { return HbTokenTypes.OPEN_INVERSE; }
  "{{"[\t \n\x0B\f\r]*"else" { return HbTokenTypes.OPEN_INVERSE; }
  "{{{" { return HbTokenTypes.OPEN_UNESCAPED; }
  "{{&" { return HbTokenTypes.OPEN_UNESCAPED; }
  // TODO handlebars.l monkeys with the buffer and changes state to INITAL.  Why?  This seems to capture the comments...
  "{{!".*?"}}" { yypopState(); return HbTokenTypes.COMMENT; }
  "{{" { return HbTokenTypes.OPEN; }
  "=" { return HbTokenTypes.EQUALS; }
  "."/[}\t \n\x0B\f\r] { return HbTokenTypes.ID; }
  ".." { return HbTokenTypes.ID; }
  [\/.] { return HbTokenTypes.SEP; }
  {WhiteSpace}+ { return HbTokenTypes.WHITE_SPACE; }
  "}}}" { yypopState(); return HbTokenTypes.CLOSE; }
  "}}" { yypopState(); return HbTokenTypes.CLOSE; }
  // dm todo get the STRING token returning properly
//  '"'("\\"["]\[^"])*'"' { zzBuffer = yytext().subSequence(1,yylength() - 2).toString().replaceAll("\\",'"'); return HbTokenTypes.STRING; }
  "true"/[}\t \n\x0B\f\r] { return HbTokenTypes.BOOLEAN; }
  "false"/[}\t \n\x0B\f\r] { return HbTokenTypes.BOOLEAN; }
  [0-9]+/[}\t \n\x0B\f\r]  { return HbTokenTypes.INTEGER; }
  [a-zA-Z0-9_$-]+/[=}\t \n\x0B\f\r\/.] { return HbTokenTypes.ID; }
  // dm todo this is trying to extract the id from within square brackets, not include the square brackets.  Fix it to match handlebars.l
  \[[^\]]*\] { return HbTokenTypes.ID; }
}

{WhiteSpace}+ { return HbTokenTypes.WHITE_SPACE; }
. { return HbTokenTypes.INVALID; }