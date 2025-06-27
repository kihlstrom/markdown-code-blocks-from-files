on getFileParts(fullPath)
	set ORIGINAL_DELIMITERS to AppleScript's text item delimiters

	set AppleScript's text item delimiters to "/"
	if fullPath contains "/" then
		set fileName to text item -1 of fullPath
	else
		set fileName to fullPath
	end if

	set AppleScript's text item delimiters to "."
	if fileName contains "." then
		set {nameOnly, fileExtension} to {text 1 thru text item -2, text item -1} of fileName
	else
		set {nameOnly, fileExtension} to {fileName, ""}
	end if

	set AppleScript's text item delimiters to ORIGINAL_DELIMITERS

	set fileType to fileExtension
	if fileName = "." & fileExtension then
		set fileType to fileName
	end if

	if fileExtension = ¬
		"js" or fileExtension = ¬
		"jsx" or fileExtension = ¬
		"mjs" or fileExtension = ¬
		"cjs" or fileExtension = ¬
		"mjsx" or fileExtension = "cjsx" then
		set fileType to "javascript"

	else if fileExtension = ¬
		"ts" or fileExtension = ¬
		"tsx" or fileExtension = ¬
		"mts" or fileExtension = ¬
		"cts" or fileExtension = ¬
		"mtsx" or fileExtension = "ctsx" then
		set fileType to "typescript"

	else if fileExtension = "scss" then
		set fileType to "scss"

	else if fileExtension = "css" then
		set fileType to "css"

	else if fileExtension = "py" then
		set fileType to "python"

	else if fileExtension = ¬
		"yml" or fileExtension = "yaml" then
		set fileType to "yaml"

	else if fileExtension = ¬
		"gql" or fileExtension = "graphql" then
		set fileType to "graphql"

	else if fileExtension = ¬
		"md" or fileExtension = "markdown" then
		set fileType to "markdown"

	else if fileExtension = "txt" then
		set fileType to "text"

	else if fileExtension = ¬
		"env" or fileName = ¬
		".env" or nameOnly = ".env" then
		set fileType to "sh"

	end if

	return {fileName, fileExtension, fileType}
end getFileParts


on getFileContentAsUtf8(filePath)
	return read POSIX file filePath as «class utf8»
end getFileContentAsUtf8


on getCodeBlockDelimiter(fileContent)
	set codeBlockDelimiter to "```"
	repeat while fileContent contains codeBlockDelimiter
		set codeBlockDelimiter to codeBlockDelimiter & "`"
	end repeat
	return codeBlockDelimiter
end getCodeBlockDelimiter


on getCodeBlockStart(codeBlockDelimiter, fileType, fileName)
	set NEWLINE to ASCII character 10
	set fileNameComment to ""

	if fileType = ¬
		"javascript" or fileType = ¬
		"typescript" or fileType = "scss" then
		set fileNameComment to "// " & fileName

	else if fileType = "css" then
		set fileNameComment to "/* " & fileName & " */"

	else if fileType = ¬
		"python" or fileType = "sh" then
		set fileNameComment to "# " & fileName

	else if fileType = "text" then
		set fileType to ""

	end if

	set codeBlockStart to (codeBlockDelimiter & fileType & NEWLINE)
	if not fileNameComment = "" then
		set codeBlockStart to codeBlockStart & fileNameComment & NEWLINE
	end if

	return codeBlockStart
end getCodeBlockStart


on run {input, parameters}
	set NEWLINE to ASCII character 10
	set output to {}

	repeat with i from 1 to length of input
		set filePath to item i of input
		set {fileName, fileExtension, fileType} to getFileParts(filePath)
		set fileContent to getFileContentAsUtf8(filePath)
		set codeBlockDelimiter to getCodeBlockDelimiter(fileContent)
		set codeBlockStart to getCodeBlockStart(codeBlockDelimiter, fileType, fileName)

		set fencedCodeBlock to ¬
			codeBlockStart & NEWLINE ¬
			& fileContent & NEWLINE ¬
			& codeBlockDelimiter & NEWLINE

		set end of output to fencedCodeBlock
	end repeat

	if length of input = 1 then
		set end of output to "Can you check this code for possible errors and also if there is a way to make this code more readable?"
	else if length of input > 1 then
		set end of output to "Can you check these files for possible errors and also if there is a way to make this code more readable?"
	end if

	set ORIGINAL_DELIMITERS to AppleScript's text item delimiters
	set AppleScript's text item delimiters to NEWLINE
	set output to output as text
	set AppleScript's text item delimiters to ORIGINAL_DELIMITERS

	return output
end run