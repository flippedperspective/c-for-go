%{
// Copyright 2015 The CC Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// Based on [0], 6.10.

package cc

import (
	"fmt"
	"os"

	"github.com/cznic/c/internal/xc"
	"github.com/cznic/golex/lex"
	"github.com/cznic/mathutil"
)
%}

%union {
	item	interface{}
	Token	xc.Token
	toks	PpTokenList
}

%token
	/*yy:token "'%c'"    */		CHARCONST		"character constant"
	/*yy:token "1.%d"    */		FLOATCONST		"floating-point constant"
	/*yy:token "%c"      */		IDENTIFIER		"identifier"
	/*yy:token "%c("     */		IDENTIFIER_LPAREN	"identifier "
	/*yy:token "%d"      */		INTCONST		"integer constant"
	/*yy:token "L'%c'"   */		LONGCHARCONST		"long character constant"
	/*yy:token "L\"%c\"" */		LONGSTRINGLITERAL	"long string constant"
	/*yy:token "<%c.h>"  */		PPHEADER_NAME		"header name"
	/*yy:token "%d"      */		PPNUMBER		"preprocessing number"
	/*yy:token "\"%c\""  */		STRINGLITERAL		"string literal"
	/*yy:token "%c"      */		MACRO_ARG		"macro argument"
	/*yy:token ""        */		MACRO_ARG_EMPTY		"empty macro argument"

	/*yy:token "\U00100000" */	PREPROCESSING_FILE	1048576	"preprocessing file prefix"	// 0x100000 = 1048576
	/*yy:token "\U00100001" */	CONSTANT_EXPRESSION	1048577	"constant expression prefix"
	/*yy:token "\U00100002" */	TRANSLATION_UNIT	1048578	"translation unit prefix"
	/*yy:token "\U00100003" */	MACRO_ARGS		1048579	"macro arguments prefix"

	/*yy:token "\n#assert"       */	PPASSERT		"#assert"
	/*yy:token "\n#define"       */	PPDEFINE		"#define"
	/*yy:token "\n#elif"         */	PPELIF			"#elif"
	/*yy:token "\n#else"         */	PPELSE			"#else"
	/*yy:token "\n#endif"        */	PPENDIF			"#endif"
	/*yy:token "\n#error"        */	PPERROR			"#error"
	/*yy:token "\n#"             */	PPHASH_NL		"#"
	/*yy:token "\n#if"           */	PPIF			"#if"
	/*yy:token "\n#ifdef"        */	PPIFDEF			"#ifdef"
	/*yy:token "\n#ifndef"       */	PPIFNDEF		"#ifndef"
	/*yy:token "\n#import"       */	PPIMPORT		"#import"
	/*yy:token "\n#ident"        */	PPIDENT			"#ident"
	/*yy:token "\n#include"      */	PPINCLUDE		"#include"
	/*yy:token "\n#include_next" */	PPINCLUDE_NEXT		"#include_next"
	/*yy:token "\n#line"         */	PPLINE			"#line"
	/*yy:token "\n#foo"          */	PPNONDIRECTIVE		"#foo"
	/*TODO                       */ PPOTHER			"ppother"
	/*yy:token "\n##"            */	PPPASTE			"##"
	/*yy:token "\n#pragma"       */	PPPRAGMA		"#pragma"
	/*yy:token "\n#unassert"     */	PPUNASSERT		"#unassert"
	/*yy:token "\n#undef"        */	PPUNDEF			"#undef"
	/*yy:token "\n#warning"      */	PPWARNING		"#warning"

	ADDASSIGN			"+="
	ANDAND				"&&"
	ANDASSIGN			"&="
	ARROW				"->"
	AUTO				"auto"
	BOOL				"_Bool"
	BREAK				"break"
	CASE				"case"
	CHAR				"char"
	COMPLEX				"_Complex"
	CONST				"const"
	CONTINUE			"continue"
	DDD				"..."
	DEC				"--"
	DEFAULT				"default"
	DEFINED				"defined"
	DIVASSIGN			"/="
	DO				"do"
	DOUBLE				"double"
	ELSE				"else"
	ENUM				"enum"
	EQ				"=="
	EXTERN				"extern"
	FLOAT				"float"
	FOR				"for"
	GEQ				">="
	GOTO				"goto"
	IF				"if"
	INC				"++"
	INLINE				"inline"
	INT				"int"
	LEQ				"<="
	LONG				"long"
	LSH				"<<"
	LSHASSIGN			"<<="
	MODASSIGN			"%="
	MULASSIGN			"*="
	NEQ				"!="
	ORASSIGN			"|="
	OROR				"||"
	REGISTER			"register"
	RESTRICT			"restrict"
	RETURN				"return"
	RSH				">>"
	RSHASSIGN			">>="
	SHORT				"short"
	SIGNED				"signed"
	SIZEOF				"sizeof"
	STATIC				"static"
	STRUCT				"struct"
	SUBASSIGN			"-="
	SWITCH				"switch"
	TYPEDEF				"typedef"
	TYPEDEFNAME			"typedefname" //TODO
	UNION				"union"
	UNSIGNED			"unsigned"
	VOID				"void"
	VOLATILE			"volatile"
	WHILE				"while"
	XORASSIGN			"^="

%type	<toks>
	PpTokenList			"token list"
	PpTokens			"token list "
	PpTokenListOpt			"optional token list"
	ReplacementList			"replacement token list"
	TextLine			"text line"

%type	<item>
	AbstractDeclarator		"abstract declarator"
	AbstractDeclaratorOpt		"optional abstract declarator"
	AdditiveExpression		"additive expression"
	AndExpression			"and expression"
	ArgumentExpressionList		"argument expression list"
	ArgumentExpressionListOpt	"optional argument expression list"
	AssignmentExpression		"assignment expression"
	AssignmentExpressionOpt		"optional assignment expression"
	AssignmentOperator		"assignment operator"
	BlockItem			"block item"
	BlockItemList			"block item list"
	BlockItemListOpt		"optional block item list"
	CastExpression			"cast expression"
	CompoundStatement		"compound statement"
	ConditionalExpression		"conditional expression"
	Constant			"constant"
	ConstantExpression		"constant expression"
	ControlLine			"control line"
	Declaration			"declaration"
	DeclarationList			"declaration list"
	DeclarationListOpt		"optional declaration list"
	DeclarationSpecifiers		"declaration specifiers"
	DeclarationSpecifiersOpt	"optional declaration specifiers"
	Declarator			"declarator"
	DeclaratorOpt			"optional declarator"
	Designation			"designation"
	DesignationOpt			"optional designation"
	Designator			"designator"
	DesignatorList			"designator list"
	DirectAbstractDeclarator	"direct abstract declarator"
	DirectAbstractDeclaratorOpt	"optional direct abstract declarator"
	DirectDeclarator		"direct declarator"
	ElifGroup			"elif group"
	ElifGroupList			"elif group list"
	ElifGroupListOpt		"optional elif group list"
	ElseGroup			"else group"
	ElseGroupOpt			"optional else group"
	EndifLine			"endif line"
	EnumSpecifier			"enum specifier"
	EnumerationConstant		"enumearation constant"
	Enumerator			"enumerator"
	EnumeratorList			"enumerator list"
	EqualityExpression		"equality expression"
	ExclusiveOrExpression		"xor expression"
	ExpressionList			"expression list"
	ExpressionOpt			"optional expression"
	ExpressionStatement		"expression statement"
	ExternalDeclaration		"external declaration"
	FunctionDefinition		"function definition"
	FunctionSpecifier		"function specifier"
	GroupList			"group list"
	GroupListOpt			"optional group list"
	GroupPart			"group part"
	IdentifierList			"identifier list"
	IdentifierListOpt		"optional identifier list"
	IdentifierOpt			"optional identifier"
	IfGroup				"if group"
	IfSection			"if section"
	InclusiveOrExpression		"inclusive-or expression"
	InitDeclarator			"init declarator"
	InitDeclaratorList		"init declarator list"
	InitDeclaratorListOpt		"optional init declarator list"
	Initializer			"initializer"
	InitializerList			"initializer list"
	IterationStatement		"iteration statement"
	JumpStatement			"jump statement"
	LabeledStatement		"labeled statement"
	LogicalAndExpression		"logical-and expression"
	LogicalOrExpression		"logical-or expression"
	MacroArgList			"macro argument list"
	MacroArgsList			"macro arguments list"
	MultiplicativeExpression	"multiplicative expression"
	ParameterDeclaration		"parameter declaration"
	ParameterList			"parameter list"
	ParameterTypeList		"parameter type list"
	ParameterTypeListOpt		"optional parameter type list"
	Pointer				"pointer"
	PointerOpt			"optional pointer"
	PostfixExpression		"postfix expression"
	PreprocessingFile		"preprocessing file"
	PrimaryExpression		"primary expression"
	RelationalExpression		"relational expression"
	SelectionStatement		"selection statement"
	ShiftExpression			"shift expression"
	SpecifierQualifierList		"specifier qualifier list"
	SpecifierQualifierListOpt	"optional specifier qualifier list"
	Statement			"statement"
	StorageClassSpecifier		"storage class specifier"
	StructDeclaration		"struct declaration"
	StructDeclarationList		"struct declaration list"
	StructDeclarator		"struct declarator"
	StructDeclaratorList		"struct declarator list"
	StructOrUnion			"struct-or-union"
	StructOrUnionSpecifier		"struct-or-union specifier"
	StructOrUnionSpecifier0		"struct-or-union specifier prolog"
	TranslationUnit			"translation unit"
	TypeName			"type name"
	TypeQualifier			"type qualifier"
	TypeQualifierList		"type qualifier list"
	TypeQualifierListOpt		"optional type qualifier list"
	TypeSpecifier			"type specifier"
	UnaryExpression			"unary expression"
	UnaryOperator			"unary operator"

%precedence	NOELSE
%precedence	ELSE

%%

//yy:ignore
Start:
	PREPROCESSING_FILE PreprocessingFile
|	CONSTANT_EXPRESSION ConstantExpression
	{
		lx.constExpr = $2.(*ConstantExpression)
	}
|	TRANSLATION_UNIT TranslationUnit
	{
		tu := $2.(*TranslationUnit).reverse()
		tu.Declarations = lx.tu.Declarations
		lx.tu = tu
		if compilation.Errors(false) == nil && (lx.scope.Type != ScopeFile || lx.compoundStmt != 0 ) {
			panic("internal error")
		}
	}
|	MACRO_ARGS '(' MacroArgsList ')'

// [0](6.4.4.3)
EnumerationConstant:
	IDENTIFIER

// [0](6.5.1)
PrimaryExpression:
	IDENTIFIER
|	Constant
|	'(' ExpressionList ')'

Constant:
	CHARCONST
|	FLOATCONST
|	INTCONST
|	LONGCHARCONST
|	LONGSTRINGLITERAL
|	STRINGLITERAL

// [0](6.5.2)
PostfixExpression:
	PrimaryExpression
|	PostfixExpression '[' ExpressionList ']'
|	PostfixExpression '(' ArgumentExpressionListOpt ')'
|	PostfixExpression '.' IDENTIFIER
|	PostfixExpression "->" IDENTIFIER
|	PostfixExpression "++"
|	PostfixExpression "--"
|	'(' TypeName ')' '{' InitializerList '}'
|	'(' TypeName ')' '{' InitializerList ',' '}'

// [0](6.5.2)
ArgumentExpressionList:
	AssignmentExpression
|	ArgumentExpressionList ',' AssignmentExpression

ArgumentExpressionListOpt:
	{
	}
|	ArgumentExpressionList

// [0](6.5.3)
UnaryExpression:
	PostfixExpression
|	"++" UnaryExpression
|	"--" UnaryExpression
|	UnaryOperator CastExpression
|	"sizeof" UnaryExpression
|	"sizeof" '(' TypeName ')'
|	"defined" IDENTIFIER
|	"defined" '(' IDENTIFIER ')'

// [0](6.5.3)
UnaryOperator:
	'&'
|	'*'
|	'+'
|	'-'
|	'~'
|	'!'

// [0](6.5.4)
CastExpression:
	UnaryExpression
|	'(' TypeName ')' CastExpression

// [0](6.5.5)
MultiplicativeExpression:
	CastExpression
|	MultiplicativeExpression '*' CastExpression
|	MultiplicativeExpression '/' CastExpression
|	MultiplicativeExpression '%' CastExpression

// [0](6.5.6)
AdditiveExpression:
	MultiplicativeExpression
|	AdditiveExpression '+' MultiplicativeExpression
|	AdditiveExpression '-' MultiplicativeExpression

// [0](6.5.7)
ShiftExpression:
	AdditiveExpression
|	ShiftExpression "<<" AdditiveExpression
|	ShiftExpression ">>" AdditiveExpression

// [0](6.5.8)
RelationalExpression:
	ShiftExpression
|	RelationalExpression '<' ShiftExpression
|	RelationalExpression '>' ShiftExpression
|	RelationalExpression "<=" ShiftExpression
|	RelationalExpression ">=" ShiftExpression

// [0](6.5.9)
EqualityExpression:
	RelationalExpression
|	EqualityExpression "==" RelationalExpression
|	EqualityExpression "!=" RelationalExpression

// [0](6.5.10)
AndExpression:
	EqualityExpression
|	AndExpression '&' EqualityExpression

// [0](6.5.11)
ExclusiveOrExpression:
	AndExpression
|	ExclusiveOrExpression '^' AndExpression

// [0](6.5.12)
InclusiveOrExpression:
	ExclusiveOrExpression
|	InclusiveOrExpression '|' ExclusiveOrExpression

// [0](6.5.13)
LogicalAndExpression:
	InclusiveOrExpression
|	LogicalAndExpression "&&" InclusiveOrExpression

// [0](6.5.14)
LogicalOrExpression:
	LogicalAndExpression
|	LogicalOrExpression "||" LogicalAndExpression

// [0](6.5.15)
ConditionalExpression:
	LogicalOrExpression
|	LogicalOrExpression '?' ExpressionList ':' ConditionalExpression

// [0](6.5.16)
AssignmentExpression:
	ConditionalExpression
|	UnaryExpression AssignmentOperator AssignmentExpression

AssignmentExpressionOpt:
	{
	}
|	AssignmentExpression

// [0](6.5.16)
AssignmentOperator:
	'='
|	"*="
|	"/="
|	"%="
|	"+="
|	"-="
|	"<<="
|	">>="
|	"&="
|	"^="
|	"|="

// [0](6.5.17)
ExpressionList:
	AssignmentExpression
|	ExpressionList ',' AssignmentExpression

ExpressionOpt:
	{
	}
|	ExpressionList

// [0](6.6)
ConstantExpression:
	ConditionalExpression

// [0](6.7)
//yy:field	IsFileScope	bool
//yy:field	IsTypedef	bool
Declaration:
	DeclarationSpecifiers InitDeclaratorListOpt ';'
	{
		lhs.IsFileScope = lx.scope.Type == ScopeFile
		sc := lx.scope
		sc.isTypedef = false
		o := lhs.InitDeclaratorListOpt
		if o == nil {
			break
		}

		for l := o.InitDeclaratorList; l != nil; l = l.InitDeclaratorList {
			d := l.InitDeclarator.Declarator
			d.DeclarationSpecifiers = lhs.DeclarationSpecifiers
			lhs.IsTypedef = d.IsTypedef
		}
	}

// [0](6.7)
//yy:field	IsAuto bool               // StorageClassSpecifier "auto" is present.
//yy:field	IsConst bool              // TypeQualifier "const" is present.
//yy:field	IsExtern bool             // StorageClassSpecifier "extern" is present.
//yy:field	IsInline bool             // FunctionSpecifier "inline" is present.
//yy:field	IsRegister bool           // StorageClassSpecifier "register" is present.
//yy:field	IsRestrict bool           // TypeQualifier "restrict" is present.
//yy:field	IsStatic bool             // StorageClassSpecifier "static" is present.
//yy:field	IsTypedef bool            // StorageClassSpecifier "typedef" is present.
//yy:field	IsVolatile bool           // TypeQualifier "volatile" is present.
//yy:field	typ int                   // One of tsVoid, tsChar, tsUChar, ...
//yy:field	typeSpecifiers int        //
DeclarationSpecifiers:
	StorageClassSpecifier DeclarationSpecifiersOpt
	{
		lhs.sum(lhs.DeclarationSpecifiersOpt)
		switch lhs.StorageClassSpecifier.Case {
		case 0: // "typedef"
			lhs.IsTypedef = true
		case 1: // "extern"
			lhs.IsExtern = true
		case 2: // "static"
			lhs.IsStatic = true
		case 3: // "auto"
			lhs.IsAuto = true
		case 4: // "register"
			lhs.IsRegister = true
		default:
			panic("internal error")
		}
		lx.scope.specifier = (*declarationSpecifiers)(lhs).Type()
	}
|	TypeSpecifier
	{
		$1.(*TypeSpecifier).bindings = lx.scope
	}
	DeclarationSpecifiersOpt
	{
		lhs.sum(lhs.DeclarationSpecifiersOpt)
		ts := lhs.TypeSpecifier
		if lhs.typeSpecifiers > 0xffffff {
			compilation.ErrTok(ts.Token, "invalid type specifier")
			lhs.typ = tsVoid
			break
		}

		c := ts.Case
		if c == tsStructOrUnion {
			c = ts.case2
		}
		lhs.typeSpecifiers = lhs.typeSpecifiers<<8 | c
		lhs.typeSum()
		lx.scope.specifier = (*declarationSpecifiers)(lhs).Type()
	}
|	TypeQualifier DeclarationSpecifiersOpt
	{
		lhs.sum(lhs.DeclarationSpecifiersOpt)
		switch lhs.TypeQualifier.Case {
		case 0: // "const"
			lhs.IsConst = true
		case 1: // "restrict"
			lhs.IsRestrict = true
		case 2: // "volatile"
			lhs.IsVolatile = true
		default:
			panic("internal error")
		}
		lx.scope.specifier = (*declarationSpecifiers)(lhs).Type()
	}
|	FunctionSpecifier DeclarationSpecifiersOpt
	{
		lhs.sum(lhs.DeclarationSpecifiersOpt)
		lhs.IsInline = true
		lx.scope.specifier = (*declarationSpecifiers)(lhs).Type()
	}

DeclarationSpecifiersOpt:
	{
	}
|	DeclarationSpecifiers

// [0](6.7)
InitDeclaratorList:
	InitDeclarator
|	InitDeclaratorList ',' InitDeclarator

InitDeclaratorListOpt:
	{
	}
|	InitDeclaratorList

// [0](6.7)
InitDeclarator:
	Declarator
	{
		lhs.Declarator.insert(lx.scope, NSIdentifiers, false)
	}
|	Declarator '=' Initializer
	{
		d := lhs.Declarator
		d.Initializer = lhs.Initializer
		d.insert(lx.scope, NSIdentifiers, true)
	}

// [0](6.7.1)
StorageClassSpecifier:
	"typedef"
	{
		lx.scope.isTypedef = true
	}
|	"extern"
|	"static"
|	"auto"
|	"register"

// [0](6.7.2)
//yy:field	bindings	*Bindings
//yy:field	case2		int 	// {tsStruct,tsUnion}
TypeSpecifier:
	"void"
|	"char"
|	"short"
|	"int"
|	"long"
|	"float"
|	"double"
|	"signed"
|	"unsigned"
|	"_Bool"
|	"_Complex"
|	StructOrUnionSpecifier
	{
		if lhs.StructOrUnionSpecifier.isUnion {
			lhs.case2 = tsUnion
			break
		}

		lhs.case2 = tsStruct
	}
|	EnumSpecifier
//yy:example "\U00100002 typedef int i; i j;"
|	TYPEDEFNAME

//yy:field	SUSpecifier	*StructOrUnionSpecifier
StructOrUnionSpecifier0:
	StructOrUnion IdentifierOpt
	{
		lx.pushScope(ScopeMembers)
		lx.scope.SUSpecifier0 = lhs
		lx.scope.isUnion = lhs.StructOrUnion.Token.Val == idUnion
		lx.scope.maxFldAlign = 1
	}

// [0](6.7.2.1)
//yy:field	Members		*Bindings
//yy:field	align
//yy:field	bindings	*Bindings
//yy:field	isUnion		bool
//yy:field	size
StructOrUnionSpecifier:
	StructOrUnionSpecifier0 '{' StructDeclarationList '}'
	{
		s0 := lhs.StructOrUnionSpecifier0
		if io := s0.IdentifierOpt; io != nil {
			lx.fileScope.insert(NSTags, io.Token, lhs)
		}
		s0.SUSpecifier = lhs
		pos := s0.StructOrUnion.Token.Pos()
		lhs.align.pos = pos
		lhs.size.pos = pos
		sc := lx.scope
		lhs.isUnion = sc.isUnion
		switch {
		case lhs.isUnion:
			lhs.align.set(sc.maxFldAlign)
			lhs.size.set(sc.maxFldSize)
		default:
			lhs.align.set(sc.maxFldAlign)
			lhs.size.set(fieldOffset(sc.fldOffset, sc.maxFldAlign))
		}
		lhs.Members = lx.popScope($4)
	}
|	StructOrUnion IDENTIFIER
	{
		lx.fileScope.insert(NSTags, lhs.Token, lhs)
		lhs.isUnion = lhs.StructOrUnion.Token.Val == idUnion
		lhs.align.set(maxAlignment)
		lhs.size.set(0)
		lhs.bindings = lx.scope
	}

// [0](6.7.2.1)
StructOrUnion:
	"struct"
|	"union"

// [0](6.7.2.1)
StructDeclarationList:
	StructDeclaration
|	StructDeclarationList StructDeclaration

/*
// [0](6.7.2.1)
StructDeclaration:
	SpecifierQualifierList StructDeclaratorList ';'
*/

// [0](6.7.2.1) extended, see [1]
StructDeclaration:
	SpecifierQualifierList StructDeclaratorListOpt ';'

// [0](6.7.2.1)
//yy:field	IsConst bool              // TypeQualifier "const" is present.
//yy:field	IsRestrict bool           // TypeQualifier "restrict" is present.
//yy:field	IsVolatile bool           // TypeQualifier "volatile" is present.
//yy:field	typ int                   // One of tsVoid, tsChar, tsUChar, ...
//yy:field	typeSpecifiers int        //
SpecifierQualifierList:
	TypeSpecifier
	{
		$1.(*TypeSpecifier).bindings = lx.scope
	}
	SpecifierQualifierListOpt
	{
		lhs.sum(lhs.SpecifierQualifierListOpt)
		ts := lhs.TypeSpecifier
		ts.bindings = lx.scope
		if lhs.typeSpecifiers > 0xffffff {
			compilation.ErrTok(ts.Token, "invalid type specifier")
			lhs.typ = tsVoid
			break
		}

		c := ts.Case
		if c == tsStructOrUnion {
			c = ts.case2
		}
		lhs.typeSpecifiers = lhs.typeSpecifiers<<8 | c
		lhs.typeSum()
		lx.scope.specifier = (*specifierQualifierList)(lhs)
	}
|	TypeQualifier SpecifierQualifierListOpt
	{
		lhs.sum(lhs.SpecifierQualifierListOpt)
		switch lhs.TypeQualifier.Case {
		case 0: // "const"
			lhs.IsConst = true
		case 1: // "restrict"
			lhs.IsRestrict = true
		case 2: // "volatile"
			lhs.IsVolatile = true
		default:
			panic("internal error")
		}
		lx.scope.specifier = (*specifierQualifierList)(lhs)
	}

SpecifierQualifierListOpt:
	{
	}
|	SpecifierQualifierList

// [0](6.7.2.1)
StructDeclaratorList:
	StructDeclarator
|	StructDeclaratorList ',' StructDeclarator

StructDeclaratorListOpt:
|	StructDeclaratorList

// [0](6.7.2.1)
//yy:field	Bits	Type	// Non nil if StructDeclarator is a bit field.
//yy:field	align
//yy:field	offset
//yy:field	size 
StructDeclarator:
	Declarator
	{
		d := lhs.Declarator
		pos := d.Ident().Pos()
		lhs.align.pos = pos
		lhs.offset.pos = pos
		lhs.size.pos = pos
		sc := lx.scope
		t := d.Type()
		sz := t.Sizeof()
		sc.maxFldSize = mathutil.Max(sc.maxFldSize, sz)
		lhs.size.set(sz)
		al := t.Alignof()
		sc.maxFldAlign = mathutil.Max(sc.maxFldAlign, al)
		lhs.align.set(al)
		fldOffset := fieldOffset(sc.fldOffset, al)
		if sc.isUnion {
			fldOffset = 0
		}
		lhs.offset.set(fldOffset)
		if !sc.isUnion {
			sc.fldOffset = fldOffset+sz
		}
		lhs.Declarator.insert(sc, NSMembers, true)
	}
//yy:example "\U00100002 struct { _Bool : 1 ,"
|	DeclaratorOpt ':' ConstantExpression
	{
		sc := lx.scope
		pos := lhs.Token.Pos()
		lhs.align.pos = pos
		lhs.offset.pos = pos
		lhs.size.pos = pos
		var t Type
		if o := lhs.DeclaratorOpt; o != nil {
			d := o.Declarator
			pos = d.Ident().Pos()
			d.insert(sc, NSMembers, true)
			t = d.Type()
		}
		t = newBitField(t, int(intT(lhs.ConstantExpression.eval()).(int32)))
		lhs.Bits = t
		al := t.Alignof()
		sz := t.Sizeof()
		sc.maxFldSize = mathutil.Max(sc.maxFldSize, sz)
		lhs.size.set(sz)
		sc.maxFldAlign = mathutil.Max(sc.maxFldAlign, al)
		lhs.align.set(al)
		fldOffset := fieldOffset(sc.fldOffset, al)
		if sc.isUnion {
			fldOffset = 0
		}
		lhs.offset.set(fldOffset)
		if !sc.isUnion {
			sc.fldOffset = fldOffset+sz
		}
	}

EnumSpecifier0:
	"enum" IdentifierOpt
	{
		lx.pushScope(ScopeMembers)
	}

// [0](6.7.2.2)
EnumSpecifier:
	EnumSpecifier0 '{' EnumeratorList '}'
	{
		if io := lhs.EnumSpecifier0.IdentifierOpt; io != nil {
			lx.fileScope.insert(NSTags, io.Token, lhs)
		}
		lx.popScope($4)
	}
|	EnumSpecifier0 '{' EnumeratorList ',' '}'
	{
		if io := lhs.EnumSpecifier0.IdentifierOpt; io != nil {
			lx.fileScope.insert(NSTags, io.Token, lhs)
		}
		lx.popScope($5)
	}
|	"enum" IDENTIFIER

// [0](6.7.2.2)
EnumeratorList:
	Enumerator
|	EnumeratorList ',' Enumerator

// [0](6.7.2.2)
Enumerator:
	EnumerationConstant //TODO declare enum const
|	EnumerationConstant '=' ConstantExpression //TODO declare enum const

// [0](6.7.3)
TypeQualifier:
	"const"
|	"restrict"
|	"volatile"

// [0](6.7.4)
FunctionSpecifier:
	"inline"

// [0](6.7.5)
//yy:field	DeclarationSpecifiers	*DeclarationSpecifiers		// Non nil if Declarator is a part of a Declaration.
//yy:field	Initializer		*Initializer			// Non nil if Declarator is part of InitDeclarator with Initializer.
//yy:field	IsDefinition		bool				// Whether Declarator is part of an InitDeclarator with Initializer or part of a FunctionDefinition.
//yy:field	IsTypedef		bool				// Declarator defines a type.
//yy:field	SUSpecifier0		*StructOrUnionSpecifier0	// Non nil if Declarator declares a field.
//yy:field	Serial			int				// Translation unit wise unique, non-zero numeric Declarator id.
//yy:field	Scope			*Bindings			// Resilution scope.
Declarator:
	PointerOpt DirectDeclarator
	{
		lx.declaratorSerial++
		lhs.Serial = lx.declaratorSerial
		lhs.DirectDeclarator.indirection = lhs.PointerOpt.indirection()
		sc := lx.scope
		lhs.IsTypedef = sc.isTypedef
		lhs.SUSpecifier0 = sc.SUSpecifier0
		lhs.Scope = lx.scope
	}

DeclaratorOpt:
	{
	}
|	Declarator

// [0](6.7.5)
//yy:field	indirection	int	// 'int **i': 2.
//yy:field	specifier	Type	// 'int i': specifier is 'int'
DirectDeclarator:
	IDENTIFIER
	{
		lhs.specifier = lx.scope.specifier
	}
|	'(' Declarator ')'
|	DirectDeclarator '[' TypeQualifierListOpt AssignmentExpressionOpt ']'
	{
		lhs.postProc(lx.scope)
	}
|	DirectDeclarator '[' "static" TypeQualifierListOpt AssignmentExpression ']'
	{
		lhs.postProc(lx.scope)
	}
|	DirectDeclarator '[' TypeQualifierList "static" AssignmentExpression ']'
	{
		lhs.postProc(lx.scope)
	}
|	DirectDeclarator '[' TypeQualifierListOpt '*' ']'
	{
		lhs.postProc(lx.scope)
	}
|	DirectDeclarator '('
	{
		lx.pushScope(ScopeFnParams)
	}
	DirectDeclarator2
	{
		p := lx.scope
		lx.popScope(lhs.DirectDeclarator2.Token)
		lx.scope.params = p
		lhs.postProc(lx.scope)
	}

DirectDeclarator2:
	ParameterTypeList ')'
|	IdentifierListOpt ')'

// [0](6.7.5)
//yy:field	indirection int
Pointer:
	'*' TypeQualifierListOpt
	{
		lhs.indirection = 1
	}
|	'*' TypeQualifierListOpt Pointer
	{
		lhs.indirection = lhs.Pointer.indirection + 1
	}

PointerOpt:
	{
	}
|	Pointer

// [0](6.7.5)
TypeQualifierList:
	TypeQualifier
|	TypeQualifierList TypeQualifier

TypeQualifierListOpt:
	{
	}
|	TypeQualifierList

// [0](6.7.5)
ParameterTypeList:
	ParameterList
|	ParameterList ',' "..."

ParameterTypeListOpt:
	{
	}
|	ParameterTypeList

// [0](6.7.5)
ParameterList:
	ParameterDeclaration
|	ParameterList ',' ParameterDeclaration

// [0](6.7.5)
ParameterDeclaration:
	DeclarationSpecifiers Declarator
	{
		lhs.Declarator.insert(lx.scope, NSIdentifiers, true)
	}
|	DeclarationSpecifiers AbstractDeclaratorOpt

// [0](6.7.5)
IdentifierList:
	IDENTIFIER
|	IdentifierList ',' IDENTIFIER

IdentifierListOpt:
	{
	}
|	IdentifierList

IdentifierOpt:
	{
	}
|	IDENTIFIER

// [0](6.7.6)
TypeName:
	SpecifierQualifierList AbstractDeclaratorOpt
	{
		if o := lhs.AbstractDeclaratorOpt; o != nil {
			o.AbstractDeclarator.specifier = (*specifierQualifierList)(lhs.SpecifierQualifierList)
		}
	}

// [0](6.7.6)
//yy:field	indirection	int	// 'int **i': 2.
//yy:field	specifier	Type	// 'int i': specifier is 'int'
AbstractDeclarator:
	Pointer
	{
		lhs.specifier = lx.scope.specifier
		lhs.indirection = lhs.Pointer.indirection
	}
|	PointerOpt DirectAbstractDeclarator
	{
		dad := lhs.DirectAbstractDeclarator
		dad.specifier = lx.scope.specifier
		dad.indirection = lhs.PointerOpt.indirection()
	}

AbstractDeclaratorOpt:
	{
	}
|	AbstractDeclarator

// [0](6.7.6)
//yy:field	indirection	int	// 'int **i': 2.
//yy:field	specifier	Type	// 'int i': specifier is 'int'
DirectAbstractDeclarator:
	'(' AbstractDeclarator ')'
|	DirectAbstractDeclaratorOpt '[' AssignmentExpressionOpt ']'
	{
		if !isExample {
			fmt.Fprintf(os.Stderr, "TODO: DirectAbstractDeclarator case %v\n%s", lhs.Case, PrettyString(lhs))
		}
	}
|	DirectAbstractDeclaratorOpt '[' TypeQualifierList AssignmentExpressionOpt ']'
	{
		if !isExample {
			fmt.Fprintf(os.Stderr, "TODO: DirectAbstractDeclarator case %v\n%s", lhs.Case, PrettyString(lhs))
		}
	}
|	DirectAbstractDeclaratorOpt '[' "static" TypeQualifierListOpt AssignmentExpression ']'
	{
		if !isExample {
			fmt.Fprintf(os.Stderr, "TODO: DirectAbstractDeclarator case %v\n%s", lhs.Case, PrettyString(lhs))
		}
	}
|	DirectAbstractDeclaratorOpt '[' TypeQualifierList "static" AssignmentExpression ']'
	{
		if !isExample {
			fmt.Fprintf(os.Stderr, "TODO: DirectAbstractDeclarator case %v\n%s", lhs.Case, PrettyString(lhs))
		}
	}
|	DirectAbstractDeclaratorOpt '[' '*' ']'
	{
		if !isExample {
			fmt.Fprintf(os.Stderr, "TODO: DirectAbstractDeclarator case %v\n%s", lhs.Case, PrettyString(lhs))
		}
	}
|	'(' ParameterTypeListOpt ')'
	{
		if !isExample {
			fmt.Fprintf(os.Stderr, "TODO: DirectAbstractDeclarator case %v\n%s", lhs.Case, PrettyString(lhs))
		}
	}
|	DirectAbstractDeclarator '(' ParameterTypeListOpt ')'
	{
		dad := lhs.DirectAbstractDeclarator
		dad.specifier = (*directAbstractDeclarator)(lhs)
		if dad.Case == 0 { //  '(' AbstractDeclarator ')'
			switch ad := dad.AbstractDeclarator; ad.Case {
			case 0: // Pointer
				ad.specifier = (*directAbstractDeclarator)(lhs)
			case 1: // PointerOpt DirectAbstractDeclarator
				ad.DirectAbstractDeclarator.specifier = (*directAbstractDeclarator)(lhs)
			}
		}
	}

DirectAbstractDeclaratorOpt:
	{
	}
|	DirectAbstractDeclarator

// [0](6.7.7) typedef-name: //TODO
// identifier

// [0](6.7.8)
Initializer:
	AssignmentExpression
|	'{' InitializerList '}'
|	'{' InitializerList ',' '}'

// [0](6.7.8)
InitializerList:
	DesignationOpt Initializer
|	InitializerList ',' DesignationOpt Initializer

// [0](6.7.8)
Designation:
	DesignatorList '='

DesignationOpt:
	{
	}
|	Designation

// [0](6.7.8)
DesignatorList:
	Designator
|	DesignatorList Designator

// [0](6.7.8)
Designator:
	'[' ConstantExpression ']'
|	'.' IDENTIFIER

// [0](6.8)
Statement:
	LabeledStatement
|	CompoundStatement
|	ExpressionStatement
|	SelectionStatement
|	IterationStatement
|	JumpStatement

// [0](6.8.1)
LabeledStatement:
	IDENTIFIER ':' Statement
|	"case" ConstantExpression ':' Statement
|	"default" ':' Statement

// [0](6.8.2)
//yy:field	Declarations	*Bindings
CompoundStatement:
	'{'
	{
		lx.compoundStmt++
		if lx.compoundStmt != 1 {
			lx.pushScope(ScopeBlock)
		}
	}
	BlockItemListOpt '}'
	{
		lhs.Declarations = lx.scope
		lx.compoundStmt--
		if lx.compoundStmt != 0 {
			lx.popScope($4)
		}

	}

// [0](6.8.2)
BlockItemList:
	BlockItem
|	BlockItemList BlockItem

BlockItemListOpt:
	{
	}
|	BlockItemList

// [0](6.8.2)
BlockItem:
	Declaration
|	Statement

// [0](6.8.3)
ExpressionStatement:
	ExpressionOpt ';'

// [0](6.8.4)
SelectionStatement:
	"if" '(' ExpressionList ')' Statement %prec NOELSE
|	"if" '(' ExpressionList ')' Statement "else" Statement
|	"switch" '(' ExpressionList ')' Statement

// [0](6.8.5)
IterationStatement:
	"while" '(' ExpressionList ')' Statement
|	"do" Statement "while" '(' ExpressionList ')' ';'
|	"for" '(' ExpressionOpt ';' ExpressionOpt ';' ExpressionOpt ')' Statement
|	"for" '(' Declaration ExpressionOpt ';' ExpressionOpt ')' Statement

// [0](6.8.6)
JumpStatement:
	"goto" IDENTIFIER ';'
|	"continue" ';'
|	"break" ';'
|	"return" ExpressionOpt ';'

// [0](6.9)
//yy:field	Declarations	*Bindings
//yy:list
TranslationUnit:
	ExternalDeclaration
|	TranslationUnit ExternalDeclaration

// [0](6.9)
ExternalDeclaration:
	FunctionDefinition
|	Declaration

// [0](6.9.1)
//yy:field	Declarations	*Bindings
FunctionDefinition:
	DeclarationSpecifiers Declarator
	{
		parScope := lx.scope.params
		lx.pushScope(ScopeFunction).copy(parScope)
		lx.compoundStmt = 0
	}
	DeclarationListOpt CompoundStatement
	{
		lhs.Declarations = lx.popScope(lhs.CompoundStatement.Token2)
		d := lhs.Declarator
		d.IsDefinition = true
		lx.scope.insert(NSIdentifiers, d.Ident(), lhs)
	}

// [0](6.9.1)
DeclarationList:
	Declaration
|	DeclarationList Declaration

DeclarationListOpt:
	{
	}
|	DeclarationList

// ========================================================== PreprocessingFile

// [0](6.10)
//yy:example	"\U00100000 #if 0\n#endif"
//yy:field	file	*token.File
PreprocessingFile:
	GroupList // No more Opt due to final '\n' injection.
	{
		lx.ast = lhs
		lhs.file = lx.file
	}

// [0](6.10)
//yy:ignore
GroupList:
	GroupPart
	{
		switch e := $1.(*GroupPart); {
		case e != nil:
			$$ = &GroupList{
				GroupPart: e,
			}
		default:
			$$ = (*GroupList)(nil)
		}
	}
|	GroupList GroupPart
	{
		switch l, e := $1.(*GroupList), $2.(*GroupPart); {
		case e == nil:
			$$ = l
		default:
			$$ = &GroupList{
				GroupList: l,
				GroupPart: e,
			}
		}
	}

GroupListOpt:
	{
	}
//yy:example	"\U00100000 \n#if 1 \n a \n#elif"
|	GroupList

// [0](6.10)
//yy:ignore
GroupPart:
	ControlLine
	{
		$$ = &GroupPart{
			ControlLine: $1.(*ControlLine),
		}
	}
|	IfSection
	{
		$$ = &GroupPart{
			IfSection: $1.(*IfSection),
		}
	}
|	PPNONDIRECTIVE PpTokenList
	{
		$$ = &GroupPart{
			Token: $1,
			PpTokenList: $2,
		}
	}
|	TextLine
	{
		if $1 == 0 {
			$$ = (*GroupPart)(nil)
			break
		}

		$$ = &GroupPart{
			PpTokenList: $1,
		}
	}

//(6.10)
IfSection:
	IfGroup ElifGroupListOpt ElseGroupOpt EndifLine

//(6.10)
IfGroup:
	PPIF PpTokenList GroupListOpt
|	PPIFDEF IDENTIFIER '\n' GroupListOpt
|	PPIFNDEF IDENTIFIER '\n' GroupListOpt

// [0](6.10)
ElifGroupList:
	ElifGroup
|	ElifGroupList ElifGroup

ElifGroupListOpt:
	{
	}
|	ElifGroupList

// [0](6.10)
ElifGroup:
	PPELIF PpTokenList GroupListOpt

// [0](6.10)
ElseGroup:
	PPELSE '\n' GroupListOpt

ElseGroupOpt:
	{
	}
|	ElseGroup

// [0](6.10)
EndifLine:
	PPENDIF PpTokenListOpt //TODO Option enabling the non std PpTokenListOpt part.

// [0](6.10)
ControlLine:
	PPDEFINE IDENTIFIER ReplacementList
|	PPDEFINE IDENTIFIER_LPAREN "..." ')' ReplacementList
|	PPDEFINE IDENTIFIER_LPAREN IdentifierList ',' "..." ')' ReplacementList
|	PPDEFINE IDENTIFIER_LPAREN IdentifierListOpt ')' ReplacementList
|	PPERROR PpTokenListOpt
|	PPHASH_NL
|	PPINCLUDE PpTokenList
|	PPLINE PpTokenList
|	PPPRAGMA PpTokenListOpt
|	PPUNDEF IDENTIFIER '\n'

	// Non standard stuff.

|	PPASSERT PpTokenList
|	PPDEFINE IDENTIFIER_LPAREN IDENTIFIER "..." ')' ReplacementList
|	PPDEFINE IDENTIFIER_LPAREN IdentifierList ',' IDENTIFIER "..." ')' ReplacementList
|	PPIDENT PpTokenList
|	PPIMPORT PpTokenList
|	PPINCLUDE_NEXT PpTokenList
|	PPUNASSERT PpTokenList
|	PPWARNING PpTokenList

// [0](6.10)
//yy:ignore
TextLine:
	PpTokenListOpt

// [0](6.10)
//yy:ignore
ReplacementList:
	PpTokenListOpt

// [0](6.10)
//yy:ignore
PpTokenList:
	PpTokens '\n'
	{
		$$ = PpTokenList(db.putTokens(lx.zipToks))
	}

//yy:ignore
PpTokenListOpt:
	'\n'
	{
		$$ = 0
	}
|	PpTokenList

//yy:ignore
PpTokens:
	PPOTHER
	{
		lx.zipToks = append(lx.zipToks[:0], $1)
	}
|	PpTokens PPOTHER
	{
		lx.zipToks = append(lx.zipToks, $2)
	}

// --------------------------------------------------------------------- macros
//yy:ignore
MacroArgsList:
	MacroArgList
	{
		n := len(lx.macroArg)
		last := lx.macroArg[n-1]
		if last.Rune != MACRO_ARG_EMPTY {
			lx.macroArgs = append(lx.macroArgs, lx.macroArg)
		}
		lx.macroArg = nil
	}
|	MacroArgsList ',' MacroArgList
	{
		lx.macroArgs = append(lx.macroArgs, lx.macroArg)
		lx.macroArg = nil
	}

//yy:ignore
MacroArgList:
	{
		lx.macroArg = append(lx.macroArg, xc.Token{Char: lex.NewChar(lx.last.Pos(), MACRO_ARG_EMPTY)})
	}
|	MacroArgList MACRO_ARG
	{
		lx.macroArg = append(lx.macroArg, $2)
	}
