lines = gets(nil)

nombres = lines.split("\n")

Parte = Struct.new(:id, :total, :items, :base, :deleted, :modified, :added)
ldctotal = 0
sources = []
partes = []
multicomment = false

nombres.size.times do |i|
	archivo = File.open(nombres[i], "r")

	archivo.each_line do |linea|
		if !/^\s*$/.match(linea) && !/^\s*[{}]+\s*$/.match(linea) && !/^\s*\/\//.match(linea) && !/\s*\/\*.*\*\//.match(linea)
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
	sources.push(partes.dup)
	partes = []
end

puts "PARTES BASE:"
sources.size.times do |j|
	sources[j].size.times do |i|
		sources[j][i].added = sources[j][i].total - sources[j][i].base + sources[j][i].deleted

		if sources[j][i].base > 0 && (sources[j][i].modified > 0 || sources[j][i].deleted > 0 || sources[j][i].added > 0)
			puts "  #{sources[j][i].id}: T=#{sources[j][i].total} I=#{sources[j][i].items} B=#{sources[j][i].base} D=#{sources[j][i].deleted} M=#{sources[j][i].modified} A=#{sources[j][i].added}"
		end
	end
end
puts "---------------------------------------------------------------------"

puts "PARTES NUEVAS:"
sources.size.times do |j|
	sources[j].size.times do |i|
		if sources[j][i].base == 0 && sources[j][i].modified == 0 && sources[j][i].deleted == 0 && sources[j][i].added > 0
			puts "  #{sources[j][i].id}: T=#{sources[j][i].total} I=#{sources[j][i].items}"
		end
	end
end
puts "---------------------------------------------------------------------"

puts "PARTES REUSADAS:"
sources.size.times do |j|
	sources[j].size.times do |i|
		if sources[j][i].base > 0 && sources[j][i].modified == 0 && sources[j][i].deleted == 0 && sources[j][i].added == 0
			puts "  #{sources[j][i].id}: T=#{sources[j][i].total} I=#{sources[j][i].items} B=#{sources[j][i].base}"
		end
	end
end
puts "---------------------------------------------------------------------"
puts "Total de LDC #{ldctotal}"
