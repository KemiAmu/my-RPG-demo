class_name SaveManager2

var Processers : Dictionary[String, SaveDataProcesser]
var NowUsing : String

func Load(address : String) -> bool:
	var file := FileAccess.open(address, FileAccess.READ)
	if file:
		var data : Dictionary = file.get_var()
		file.close()
		for i in data:
			var proc := Processers[i]
			if proc:
				proc.Load(data[i])
		return true
	else:
		return false

func Save(address : String = NowUsing) -> bool:
	var data : Dictionary
	for i in Processers:
		data.get_or_add(i, Processers[i].Save())
	var file := FileAccess.open(address, FileAccess.WRITE)
	if file:
		file.store_var(data)
		file.close()
		return true
	return false
