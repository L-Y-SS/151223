def register():
  db = ("database.txt", "r")
  username = input("Create username: ")
  password = input("Create password:" )
  password1  = input("Confirm password: ")

  if password != password1:
    print("passwords do not match, restart")
    register()
  else:
    if len(password)<=6:
      print("password too short, restart:")
      register()
    elif username in db:
          print("username exists")
          register()
    else:
      db = open ("datatbase.txt", "a")
      db.write(username+","+password+"\n")
      print("success")

register()
  
