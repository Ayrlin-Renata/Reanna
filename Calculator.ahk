#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include %A_ScriptDir%/ExprEval.ahk
#SingleInstance Force

calcInput := 0
calcDelInput := 1
calcLock := 0
unitDoOutput := 1
global ansArray := Array(0)
global eValue := 2.718281828459045235360287471352662497757247093699959574966967
global piValue := 3.141592653589793238462643383279502884197169399375105820974944
return

:?:--u:: 
if(calcInput = 0) { ; If not set to display a GUI for input...
	Input, input,V,= ; Listen for key inputs until the '=' key is typed.
	if(calcDelInput) { ; If set to remove the input...
		SendInput % "{BS " StrLen(input)+1 "}" ; Backspace everything just typed.
	}
} else {
	InputBox, input, CalculatorInput, Enter an expression to evaluate.
	Sleep, 100 ; Delay so that nothing goes wrong due to lag.
	if(!calcDelInput) { ; If set to display input...
		SendInput, {raw}%input%= ; Take the input from the input GUI and write it out.
	}
}
; ------ INPUT PREPROCESSING ------ ;
ansPos := RegExMatch(input,"ans((\d)*)",ansMatch) ; Replace ans% with the correct previous answer.
if(ansMatch1 == "") { 
} else if(ansMatch1 > 0) {
	input := RegExReplace(input,"ans" . ansMatch1,ansArray[ansArray.MaxIndex() - ansMatch1 + 1]) 
}
;firstspace
spacepos := InStr(input," ")
num := SubStr(input, 1, spacepos-1)
instr := SubStr(input, spacepos+1)
result := ""
u1 := ""
u2 := ""
switch instr {
	case "f.c" : 
		result := SubStr(sevaluate("(" . num . "-32)*(5/9)"),1,-3)
		u1 := "°F"
		u2 := "°C"
	case "c.f" :
		result := SubStr(sevaluate(num . "*(9/5)+32"),1,-3)
		u1 := "°C"
		u2 := "°F"
	case "f.k" : 
		result := sevaluate("(" . num . "-32)*(5/9)+273.15")
		u1 := "°F"
		u2 := "°K"
	case "c.k" :
		result := sevaluate(num . "+273.15")
		u1 := "°C"
		u2 := "°K"
	case "k.f" :
		result := SubStr(sevaluate("(" . num . " - 273.15)*(9/5)+32"),1,-3)
		u1 := "°K"
		u2 := "°F"
	case "k.c" : 
		result := SubStr(sevaluate(num . "-273.15"),1,-3)
		u1 := "°K"
		u2 := "°C"
	case "ft.m" : 
		result := SubStr(sevaluate(num . "/3.281"),1,-3)
		u1 := "ft"
		u2 := "m"
	case "m.ft" : 
		result := SubStr(sevaluate(num . "*3.281"),1,-3)
		u1 := "m"
		u2 := "ft"
	default: result := "unknown conversion"
}
if(unitDoOutput) {
	SendInput, %result% %u2% (%num% %u1%)
} else {
	SendInput, %result% %u2%
}
return

::--udo:: ;unit do output
unitDoOutput := !unitDoOutput
return

:?:--c:: 
calcLoop := true
while(calcLoop) 
{ ; While doesn't work with OTB style, style nazis! =P
	if(calcInput = 0) { ; If not set to display a GUI for input...
		Input, input,V,= ; Listen for key inputs until the '=' key is typed.
		if(calcDelInput) { ; If set to remove the input...
			SendInput % "{BS " StrLen(input)+1 "}" ; Backspace everything just typed.
		}
	} else {
		InputBox, input, CalculatorInput, Enter an expression to evaluate.
		Sleep, 100 ; Delay so that nothing goes wrong due to lag.
		if(!calcDelInput) { ; If set to display input...
			SendInput, {raw}%input%= ; Take the input from the input GUI and write it out.
		}
	}
	; ------ INPUT PREPROCESSING ------ ;
	StringReplace, input, input,^,**,A ; Replace ^ with **, quirk of the expression evaluation.
	input := RegExReplace(input,"(\d)\(","$1*(") ; Replace a(b) with a*(b).
	ansPos := RegExMatch(input,"ans((\d)*)",ansMatch) ; Replace ans% with the correct previous answer.
	if(ansMatch1 == "") { 
	} else if(ansMatch1 > 0) {
		input := RegExReplace(input,"ans" . ansMatch1,ansArray[ansArray.MaxIndex() - ansMatch1 + 1]) 
	}
	StringReplace, input, input,e,%eValue%,A ; Replace e with the value of e.
	StringReplace, input, input,pi,%piValue%,A ; Replace pi with the value of pi.
	evaluate(input) ; EVALUATE! EVALUATE!
	if(!calcLock) { ; Keep reading in inputs if set to calc lock.
		calcLoop := false
	}
}
return

::--ci::
calcInput := !calcInput
return

::--cid:: 
if(calcInput = 0) {
	SendInput, Text mode.
} else {
	SendInput, Window mode.
}
return

::--cdi::
calcDelInput := !calcDelInput
return

::--cdid:: 
if(calcDelInput = 0) {
	SendInput, Keep input.
} else {
	SendInput, Delete input.
}
return

::--clk:: 
calcLock := !calcLock
return

::--wcalc:: 
Run, calc
return

; should probably use sendRaw or something past the first one cuz this is reliable for different format text boxes but slow. 
::--chelp:: 
SendInput, Type "--chelp " in a multi-line text box to view full help. `n
SendInput, In text mode, type "--c ", your expression, then "=". `n
SendInput, In window mode type "--c ", enter your expression, then click "OK".`n
SendInput, Type "--ci " to toggle between these input modes, or "--cid " to display the current mode.`n
SendInput, Type "--cdi " to choose whether or not the input text is erased when you enter your expression.`n
SendInput, "--cdid " will display the current setting for the aforementioned setting. `n
SendInput, "--c --clk " will continuously evaluate your input until "--clk " is typed again, then once more.`n
SendInput, "--u " enters unit conversion mode, even I don't know what that does. I wrote it like forever ago, i'll look at it later.`n`n
SendInput, Using the arrow keys while entering an expression in text mode *WILL* mess it up and may delete stuff.`n`n
SendInput, Previous answers can be expressed as 'ans' followed by a number, from 1 to about 9 quintillion.`n
SendInput, For easy access to the windows calculator, you can type "--wcalc ". Type "--chelpf" for function help.`n
SendInput, Script by Ayrlin Renata. Discord: @ayrlin, Twitter: @ayrlinrenata `n
return

::--chelpf:: 
SendInput, List of functions: abs(n), ceil(n), floor(n), log(n), ln(n), sqrt(n), sin(n), cos(n), tan(n), ["-chelpf2" to continue.]`n
::-chelpf2::
SendInput, mod(n1,n2), asin(n), acos(n), atan(n), exp(n) [Calculates e{^}n], round(n1,n2) [Rounds n1 to n2 decimal places.] 
return

sevaluate(x=000){
    x := exprCompile(x)
    x := exprEval(x)
    return x
}

evaluate(x=000){
    x := exprCompile(x)
    x := exprEval(x)
    SendInput, %x%
    ansArray.Insert(x)
}
