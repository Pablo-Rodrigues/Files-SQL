'Quellon Sistemas do Brasil S.A
'Autor:Maikon Pablo Rodrigues

strPasta="C:\SFTP\"

set FSo = CreateObject("Scripting.FileSystemObject")

Apagar_Arquivos(strPasta)


Sub Apagar_Arquivos(Pasta)

	set folder = FSO.getFolder (Pasta)

	'Verifica se tem subpastas
	if folder.Subfolders.count > 0 then
		for each SubFolder in folder.Subfolders
			'Caminho sem \ no final
				if ucase(subfolder.path)<>"C:\SFTP\LIBQUELLON" then
					Apagar_Arquivos SubFolder
				end if
		next
	end if

 
	for each file in folder.files
		if (dateDiff("d", file.DateLastModified, now) >30) then
			File.delete
		end if
	next 

end sub  