main: main.rb
	ruby main.rb
test2: main.rb
	ruby main.rb < test2.txt
out: main.rb
	ruby main.rb > out.txt
