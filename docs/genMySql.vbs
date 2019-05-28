'Author:zmofun@163.com
'All Rights Reserved
'Begin:2012-1-18 16:30
'First Test Passed:2012-1-18 18:39

isDebug=False

BaseDir=createobject("Scripting.FileSystemObject").GetFile(Wscript.ScriptFullName).ParentFolder.Path

GenFileSaveDir=BaseDir+"/sql/"  '����������/�ַ�
sqlFileName="createTable"
sqlFKDropFileName="dropForeignKey"
sqlFKAddFileName="addForeignKey"

Version="Ver1"

Dim   oShell 
Set   oShell   =   WScript.CreateObject   ("WSCript.shell")   

Set oDOC = CreateObject("Word.Application")
oDOC.Visible=True
oDOC.Documents.Open BaseDir+"/��е��Ʒ��Э�ӹ���Ϣ����ϵͳ-���ݱ����-zmofun.docx" 
'�ȴ�WORD�ĵ�ȫ����
'WScript.Sleep 3500 

sqlFileName=GenFileSaveDir+sqlFileName+Version+".sql"

'ѡ��adodb.streamʵ��ʹ��UTF-8дSQL�ļ�
Set sqlFile=CreateObject("adodb.stream")
sqlFile.Type=2 
sqlFile.mode=3 
sqlFile.charset="UTF-8"
sqlFile.open 


createSql=""

For Each tbl In oDOC.ActiveDocument.Tables

  If tbl.Rows.Count>=1 Then
    'ȡ���ĵ�һ�У���һ�У�������ֵΪTABLE��DATA�����Ǳ���������ݷ���
    cellStr=tbl.Rows(1).Cells(1).Range.Text
    'MsgBox(cellStr)
    tblType=Mid(cellStr,1,Len(cellStr)-2 )
    tblType=UCase(tblType)
    tblType=Trim(tblType)

    If(isDebug) Then
      MsgBox tblType
    End If
    
    If InStr(tblType,"TABLE")>0 Then
      rowNum=0
  	  commentSql=""
  	  primaryKeySql=""
  	  foreignKeySql=""
	  For Each row In tbl.Rows
	    rowNum=rowNum+1
	    If rowNum=1 Then
	      cellStr=row.Cells(2).Range.Text
	      tblName= Mid(cellStr,1,Len(cellStr)-2 )
	      tblName=UCase(tblName)
	      'MsgBox(tblName)
	      
	      cellStr=row.Cells(3).Range.Text
	      tblComment=Mid(cellStr,1,Len(cellStr)-2 )  
	      createSql=createSql+"DROP TABLE IF EXISTS `"+tblName+"`;"+" -- "+tblComment+Chr(13)+Chr(10)
		  createSql=createSql+"CREATE TABLE `"+tblName+"`("+" -- "+tblComment+Chr(13)+Chr(10)
	      commentSql="ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='"+tblComment+"';"+Chr(13)+Chr(10)
	      
	    End If
	
		If rowNum>2 Then
		  cellStr=row.Cells(1).Range.Text
	      colName= Mid(cellStr,1,Len(cellStr)-2 )
	      colName=UCase(colName)
		  cellStr=row.Cells(3).Range.Text
	      colType= Mid(cellStr,1,Len(cellStr)-2 )
	      colType=UCase(colType)
		  cellStr=row.Cells(4).Range.Text
	      notNULL= Mid(cellStr,1,Len(cellStr)-2 )
	      notNULL=UCase(notNULL)
	      
		  
		  isPrimaryKey="0"
	      If colName="ID" Then
	        colType="bigint(15) NOT NULL AUTO_INCREMENT"
	        primaryKeySql=" primary key (`"+colName+"`)"
	        isPrimaryKey="1"
		  End If
	      

		  If InStr(colName,"ID")>1 Then  '�ֶ�������ID����,���������
		  	foreignTblName= Mid(colName,1,Len(colName)-2 )
	  
  		    fkName=foreignTblName+"_ID"
			If(Len(fkName)>27) Then
			  start=Len(fkName)-27
			  fkName=Mid(fkName,start,28)
			Else
			  fkName=fkName
			End If
		    foreignKeySql=foreignKeySql+" CONSTRAINT `F_"+tblName+"_"+fkName+"` FOREIGN KEY (`"+colName+"`) REFERENCES `"+foreignTblName+"`(`ID`),"+Chr(13)+Chr(10)
	      End If 
	      
	      createSql=createSql+"  "+colName+"  "+colType+",--"+colComment+Chr(13)+Chr(10)
		End If
	  Next 'rows
	  createSql=createSql+foreignKeySql
	  createSql=createSql+primaryKeySql+Chr(13)+Chr(10)
	  createSql=createSql+")"+commentSql+Chr(13)+Chr(10)

	 
	End If 'tblType="TABLE"
	
  End If 'tbl.Rows.Count>=1
Next 'tables


sqlFile.WriteText(createSql)

oDOC.Quit(0)


sqlFile.SaveToFile sqlFileName ,2
sqlFile.Flush
sqlFile.close

Set oShell=Nothing   
