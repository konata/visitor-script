'''
cls
@echo off
cd/d "%~dp0"

set path=%~dp0python3\DLLs;%path%

cd python3
python.exe "%~0"

goto:eof
'''

# coding=utf-8
import xlrd
import os
from os.path import isfile
from dateutil.parser import parse
from sys import argv
import sys

LEAVE_DATE_COL = u'出院日期'

def get_all_files(_dir):
	return [os.path.join(_dir,f) for f in os.listdir(_dir) if f.endswith('.xls')]

def get_sheets_by_name(fname,idx):
	wb = xlrd.open_workbook(fname)
	return wb.sheet_by_index(idx)

def determine_leave_col(sheet):
	row = sheet.row(0)
	position = -1 # default col count for leave date
	for idx, cell in enumerate(row):
		if cell.value.replace(r" ","").find(LEAVE_DATE_COL) != -1:
			position = idx
	return position

def move_over_iter(sheet,position):
	record = []
	rows = sheet.nrows
	cur = parse("")
	record.append(sheet.row(0))
	for pos in range(1,rows):
		cell = sheet.cell(pos,position)
		try:
			leave_time = parse(cell.value)
			days  = (cur - leave_time).days
			if days in [30,60,90,365]:
				record.append(sheet.row(pos))
		except :
			pass
	return record


def write_back(_dir,rec):
	filename = os.path.join(_dir,str(parse("").date()) + ".txt");
	try:
		os.rm(filename)
	except:
		pass

	f = open(filename,"w",encoding="utf-8")
	for key,value in rec.items():
		f.write((u"======  " + key + u"========\n"))
		f.write(key)
		for record in value: # each item in record
			 f.write(" # ".join(map(lambda n: n.value.replace(" ","") , record)) + "\n")
		f.write("\n")

def format_to_html():
	

def main():
	_dir = os.path.dirname(os.getcwd())
	print(u"使用目录 %s 作为存放Excel的目录\n" % _dir)
	names_dict = {}
	files = get_all_files(_dir)

	print (u"共发现%d个excel文件:" %len(files))
	print ("\n".join(files))
	print ("\n")

	for f in files:
		try:
			sheet = get_sheets_by_name(f,0)
			idx = determine_leave_col(sheet)
			if idx != -1:
				should_visit = move_over_iter(sheet,idx)
				names_dict[f] = should_visit
			else:
				print(u"文件 %s 中未找到 %s 栏" %(f,LEAVE_DATE_COL))
		except :
			pass


	write_back(_dir,names_dict)
	filename = os.path.join(_dir,str(parse("").date()) + ".txt");
	print (u"结果写入文件%s 中\n" %filename)
	print (u"按照任意键结束")
	input()



if __name__ == '__main__':
	main()