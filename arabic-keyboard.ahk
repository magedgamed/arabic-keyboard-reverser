#NoEnv
; AHK 1.1+
Arabic := 0x01
Return


CheckKeyboardLayout(PrimaryLanguageID) {
   If !(HWND := WinExist("A"))
      Return False
   If !(ThreadID := DllCall("User32.dll\GetWindowThreadProcessId", "UInt", HWND, "UInt", 0, "UInt"))
      Return False
	   HKL := DllCall("User32.dll\GetKeyboardLayout", "UInt", ThreadID, "UInt")
   If ((HKL & 0xFF) = PrimaryLanguageID)
      Return True
   Return False
}


HasVal(haystack, needle) {
  for index, value in haystack
      if (value = needle)
          return index
  if !(IsObject(haystack))
      throw Exception("Bad haystack!", -1, haystack)
  return 0
}

GetConnectedChar(char, prev, next) {
	; keys := { "ا": "ﺎ", "ب": "ﺐ	|ﺒ|ﺑ", "ت": "ﺖ|ﺘ|ﺗ", "ث": "ﺚ|ﺜ|ﺛ", "ج": "ﺞ|ﺠ|ﺟ", "ح": "ﺢ|ﺤ|ﺣ" }
	keys := { 0x0627: [0xFE8E], 0x0628: [0xFE90, 0xFE92, 0xFE91], 0x062A: [0xFE96,0xFE98,0xFE97], 0x062B: [0xFE9A,0xFE9C,0xFE9B], 0x062C: [0xFE9E,0xFEA0,0xFE9F], 0x062D: [0xFEA2,0xFEA4,0xFEA3], 0x062E: [0xFEA6,0xFEA8,0xFEA7], 0x062F: [0xFEAA], 0x0630: [0xFEAC], 0x0631: [0xFEAE], 0x0632: [0xFEB0], 0x0633: [0xFEB2,0xFEB4,0xFEB3], 0x0634: [0xFEB6,0xFEB8,0xFEB7], 0x0635: [0xFEBA,0xFEBC,0xFEBB], 0x0636: [0xFEBE,0xFEC0,0xFEBF], 0x0637: [0xFEC2,0xFEC4,0xFEC3], 0x0638: [0xFEC6,0xFEC8,0xFEC7], 0x0639: [0xFECA,0xFECC,0xFECB], 0x063A: [0xFECE,0xFED0,0xFECF], 0x0641: [0xFED2,0xFED4,0xFED3], 0x0642: [0xFED6,0xFED8,0xFED7], 0x0643: [0xFEDA,0xFEDC,0xFEDB], 0x0644: [0xFEDE,0xFEE0,0xFEDF], 0x0645: [0xFEE2,0xFEE4,0xFEE3], 0x0646: [0xFEE6,0xFEE8,0xFEE7], 0x0647: [0xFEEA,0xFEEC,0xFEEB], 0x0648: [0xFEEE], 0x064A: [0xFEF2,0xFEF4,0xFEF3], 0x0622: [0xFE82], 0x0629: [0xFE94], 0x0649: [0xFEF0] }

	if (Ord(char) = 32) 
		Return "___"
	else if !(keys.HasKey(Ord(char)))
		Return char

	conPrev := false
	conNext := false
	key := keys[Ord(char)]
	prevKey := keys[Ord(prev)]
	nextKey := keys[Ord(next)]

	if (prevKey and key[1] and prevKey[3])
		conPrev = true
	if (nextKey and key[3] and nextKey[1])
		conNext = true

	if (conPrev and conNext)
		Return Chr(key[2])
	else if (conPrev)
		Return Chr(key[1])
	else if (conNext)
		Return Chr(key[3])
	else
		Return Chr(key[1]-1)
}


GetConnectedString(string) {
	nStr := ""
	CharsArray := StrSplit(string)
	for index, element in CharsArray {
		char := GetConnectedChar(element, CharsArray[index-1], CharsArray[index+1])
		nStr = %char%%nStr%
	}
	Return StrReplace(nStr, "___", A_Space)
}


#If CheckKeyboardLayout(Arabic) ; the following remappings will be used only if the condition resolves to true

	Left::Right
	Right::Left

	^Enter::
		Input, OutputVar, L35, {Enter}

		Clipboard := GetConnectedString(OutputVar)

		Send ^v
	Return
#If                             ; end of conditional hotkeys

+Enter::	
	title := "اكتب بالعربي"
	subtitle := "حاول ان تجعل الرسالة اقل من 40 حرف حتى لا يتم اقتطاع جزء منها داخل اللعبة"
	InputBox UserInput, %title%, %subtitle%, , 290, 150, , , Locale

	Output := GetConnectedString(userInput)

	; MsgBox %Output%
	; Send %Output%
	Clipboard := Output
	Send ^v
return
