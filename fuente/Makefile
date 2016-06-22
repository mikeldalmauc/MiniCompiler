FLAGS=-Wall
DP=../Pruebas/
FUENTES=parser.cpp main.cpp tokens.cpp Codigo.cpp

all: parser prueba

dot: bison dott

pruebas: prueba

clean:
	rm parser.cpp parser.hpp parser tokens.cpp *~ parser.dot parser.pdf parser.output parser.tab.c

parser.cpp parser.hpp: parser.y Codigo.hpp Aux.hpp
	bison -d -o $@ $<

tokens.cpp: tokens.l parser.hpp Aux.hpp
	lex -o $@ $^

parser:$(FUENTES) Codigo.hpp Aux.hpp
	g++ $(CFLAGS) -o $@ $(FUENTES) 

bison: parser.y
	bison -r all -g $^

dott: parser.dot
	dot -Tpdf $^ -o parser.pdf

prueba:  parser $(DP)PruebaBuena1.dat $(DP)PruebaBuena2.dat $(DP)PruebaMala1.dat $(DP)PruebaMala2.dat $(DP)PruebaMala3.dat $(DP)PruebaMala4.dat $(DP)PruebaMala5.dat $(DP)PruebaMala6.dat
	./parser < $(DP)PruebaBuena1.dat
	./parser < $(DP)PruebaBuena2.dat
	./parser < $(DP)PruebaMala1.dat
	./parser < $(DP)PruebaMala2.dat
	./parser < $(DP)PruebaMala3.dat
	./parser < $(DP)PruebaMala4.dat
	./parser < $(DP)PruebaMala5.dat
	./parser < $(DP)PruebaMala6.dat
