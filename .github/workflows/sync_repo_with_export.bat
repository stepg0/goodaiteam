@echo off
setlocal EnableDelayedExpansion

set "fileMask=*"

REM FolderWithChanges is the exported power apps
set "FolderWithChanges=%1"
REM FolderStartingPoint is the local repo
set "FolderStartingPoint=%2"



REM fc https://learn.microsoft.com/de-de/windows-server/administration/windows-commands/fc result of fc -> ERRORLEVEL
REM errorlevel: 0  / No differences encountered -> do not overwrite
REM errorlevel: 1  / Different file -> take file from FolderWithChanges
REM errorlevel: 2  / Cannot find file ->  -> take file from FolderWithChanges
REM errorlevel: -1 / Invalid syntax

echo cd %FolderStartingPoint% 
REM ----------- Check target folder exist, if not, create it --------------
cd %FolderStartingPoint% 2>NUL && cd.. || mkdir %FolderStartingPoint%


REM ----------- START DELETE from REPO --------------
REM list all folders in FolderStartingPoint recursively
echo list all folders in FolderStartingPoint recursively 
for /f "delims=" %%D in ('echo "."^&forfiles /s /p "%FolderStartingPoint%" /m "%fileMask%" /c "cmd /c if @isdir==TRUE echo @relpath"') do (
	REM debug echo directory "%%D"
	
	for /f "delims=" %%F in ('dir /b "%FolderStartingPoint%\%%D"') do (
		REM ignore folders
		if NOT exist "%FolderStartingPoint%\%%D\%%F\*" (
			REM Cannot find file -> remove from folder
			if NOT exist "%FolderWithChanges%\%%D\%%F" (
				del "%FolderStartingPoint%\%%D\%%F"
				echo Remove from FolderStartingPoint "%%F"
			)
			REM debug echo file "%%F"
		)
	)
)

REM remove empty folders
for /f "delims=" %%d in ('dir "%FolderStartingPoint%" /s /b /ad ^| sort /r') do rd "%%d" > NUL 2>NUL

REM ----------- END DELETE from REPO --------------



REM ----------- START COPY from EXPORT --------------
REM list all folders in FolderWithChanges recursively
for /f "delims=" %%D in ('echo "."^&forfiles /s /p "%FolderWithChanges%" /m "%fileMask%" /c "cmd /c if @isdir==TRUE echo @relpath"') do (
	REM debug echo directory "%%D"
	
	for /f "delims=" %%F in ('dir /b "%FolderWithChanges%\%%D"') do (
		REM ignore folders
		if NOT exist "%FolderWithChanges%\%%D\%%F\*" (
			if exist "%FolderStartingPoint%\%%D\%%F" (
				REM compare files in FolderStartingPoint, remove "> NUL 2>NUL" parameter to check compare result, replace with  >> out.txt to write echo to file
				fc /l /t "%FolderWithChanges%\%%D\%%F" "%FolderStartingPoint%\%%D\%%F" > NUL 2>NUL
				REM debug echo file comparison result "%%F" -- "!errorlevel!" >> out.txt
				REM Different file -> take file from FolderWithChanges
				if "!errorlevel!" EQU "1" (
					copy "%FolderWithChanges%\%%D\%%F" "%FolderStartingPoint%\%%D\%%F" 
					echo Copied from FolderWithChanges "%%F"
				)
			) else (
				REM Cannot find file -> take file from FolderWithChanges
				REM create folder structure first
				xcopy /S /Q /Y /F "%FolderWithChanges%\%%D\" "%FolderStartingPoint%\%%D\"
				REM copy file
				copy "%FolderWithChanges%\%%D\%%F" "%FolderStartingPoint%\%%D\%%F"
				echo Copied from FolderWithChanges "%%F"
			)
			REM debug echo file "%%F"
		)
	)
)
REM ----------- END COPY from EXPORT --------------
