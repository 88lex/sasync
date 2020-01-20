import sys
import gspread
from oauth2client.service_account import ServiceAccountCredentials
import httplib2
from httplib2 import Http
import os
import subprocess
import json
import datetime
import re

scope = ['https://spreadsheets.google.com/feeds',
         'https://www.googleapis.com/auth/drive']

credentials = ServiceAccountCredentials.from_json_keyfile_name('/opt/sa/1.json', scope)
gc = gspread.authorize(credentials)
#print(gc)
gsheet = 'RemoteSize'
sh = gc.open(gsheet)
worksheet = sh.worksheet("Sheet1")
remotes = worksheet.col_values(1)

try:
    remotes = [rem for rem in remotes if sys.argv[1] in rem]
    print(f"Updating size for these remotes in {gsheet}")
    for i in remotes:
        print(f"\t{i}")
except:
    pass

try:
    if not any(remotes):
        remotes = subprocess.check_output(f"rclone listremotes | egrep -h {sys.argv[1]}", shell=True, universal_newlines=True).splitlines()
        print(f"Adding remotes to {gsheet}")
        for i in remotes:
            print(f"\t{i}")
except:
    print(f"No remotes in gsheet or rclone config that match {sys.argv[1]}")
    exit()

#print(remotes)
#exit()

for remote in remotes:
    try:
        print(f"Remote is {remote}")
        rem_size = subprocess.check_output(f"rclone size --json {remote} --fast-list --exclude /backup/**", shell=True)
        parsed_json = json.loads(rem_size)
        print(json.dumps(parsed_json, indent=4, sort_keys=True))

        remcount = int(parsed_json['count'])
        remsize = int(parsed_json['bytes'])
        remsizeGB = int(parsed_json['bytes'] / (1024**3))
        nowtime = str(datetime.datetime.now())

        print(f"Remote name          = {remote}")
        print(f"Remote file count    = {remcount}")
        print(f"Remote size in GB    = {remsizeGB}")
        print(f"Remote size in bytes = {remsize}")

        try:
            cell = worksheet.find(remote)
            print(f"Found string {remote} in Row {cell.row}, Column {cell.col}")
            range_build = 'A' + str(cell.row) + ':E' + str(cell.row)
            print(range_build)
            cell_list = worksheet.range(range_build)
            cell_values = [remote, remcount, remsizeGB, remsize, nowtime]
            for i, val in enumerate(cell_values):
                cell_list[i].value = val
            print(cell_list[2].value)
            worksheet.update_cells(cell_list)
        except:
            print(f"Remote {remote} not found, add line")
            cell_values = [remote, remcount, remsizeGB, remsize, nowtime]
            worksheet.append_row(cell_values)
    except:
        pass

exit()
