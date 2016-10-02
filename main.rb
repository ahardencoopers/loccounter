lines = gets(nil)

nombres = lines.split("\n")

Parte = Struct.new(:id, :total, :items, :base, :deleted, :modified, :added)
ldctotal = 0
partes = []
multicomment = false
nombres.size.times do |i|
	archivo = File.open(nombres[i], "r")

	archivo.each_line do |linea|
		if !/^\s*$/.match(linea) && !/^\s*[{}();]+\s*$/.match(linea) && !/^\s*\/\//.match(linea) && !/\s*\/\*.*\*\//.match(linea)
			if /^\s*\/\*.*/.match(linea)
				multicomment = true
			end

			if /\*\//.match(linea)
				multicomment = false
				next
			end
                        
			if !multicomment
				if /\/\/&m\s*$/.match(linea)
					partes[-1].modified = partes[-1].modified + 1
				end
				ldctotal = ldctotal + 1
				if partes.size > 0
					partes[-1].total = partes[-1].total + 1
				end
			end
		else
			if /\/\/&b=\d*/.match(linea)
				base = linea.chomp.split("=")[1].to_i
				partes[-1].base = partes[-1].base + base
			end
			if /\/\/&d=\d*/.match(linea)
				deleted = linea.chomp.split("=")[1].to_i
				partes[-1].deleted = partes[-1].deleted + deleted
			end
			if /\/\/&i/.match(linea)
				partes[-1].items = partes[-1].items + 1
			end
			if /\/\/&p\-/.match(linea)
				parte = Parte.new("", 0, 0, 0, 0, 0, 0)
				idparte = linea.chomp.split("-")[1]
				parte.id = idparte
				partes.push(parte)
			end
		end
	end
end


puts "PARTES BASE:"
partes.size.times do |i|
	partes[i].added = partes[i].total - partes[i].base + partes[i].deleted

	if partes[i].base > 0 && (partes[i].modified > 0 || partes[i].deleted > 0 || partes[i].added > 0)
		puts "  #{partes[i].id}: T=#{partes[i].total} I=#{partes[i].items} B=#{partes[i].base} D=#{partes[i].deleted} M=#{partes[i].modified} A=#{partes[i].added}"
	end
end
puts "---------------------------------------------------------------------"

puts "PARTES NUEVAS:"
partes.size.times do |i|
	if partes[i].base == 0 && partes[i].modified == 0 && partes[i].deleted == 0 && partes[i].added > 0
		puts "  #{partes[i].id}: T=#{partes[i].total} I=#{partes[i].items}"
	end
end
puts "---------------------------------------------------------------------"

puts "PARTES REUSADAS:"
partes.size.times do |i|
	if partes[i].base > 0 && partes[i].modified == 0 && partes[i].deleted == 0 && partes[i].added == 0
		puts "  #{partes[i].id}: T=#{partes[i].total} I=#{partes[i].items} B=#{partes[i].base}"
	end
end
puts "---------------------------------------------------------------------"
puts "Total de LDC #{ldctotal}"
