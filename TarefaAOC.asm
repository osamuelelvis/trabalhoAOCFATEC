.data
	ano1: .asciiz "Digite o primeiro ano: "
	ano2: .asciiz "Digite o segundo ano: "
	qtd_bissextos: .asciiz "A quantidade de ano(s) bissexto(s) que existem é de: "
	fora_intervalo: .asciiz "\nO intervalo digitado não pode ser maior do que 1000."
	anos_iguais: .asciiz "Os anos informados são iguais!"
.text
main:
	# Imprime a mensagem para solicitar o primeiro ano
	li $v0, 4
	la $a0, ano1
	syscall
	
	# Lê o primeiro ano e guarda em $t0
	li $v0, 5
	syscall
	move $t0, $v0
	
	# Imprime a mensagem para solicitar o segundo ano
	li $v0, 4
	la $a0, ano2
	syscall
	
	# Lê o segundo ano e guarda em $t1
	li $v0, 5
	syscall
	move $t1, $v0
	
	# Verifica qual dos dois anos é maior para organizar $t3 (maior) e $t4 (menor)
	bgt $t1, $t0, maior_ano
	j menor_ano
	
menor_ano:
	# $t0 é o maior ano, $t1 é o menor
	move $t3, $t0 # $t3 = maior ano
	move $t4, $t1 # $t4 = menor ano
	move $t5, $t4 # $t5 = ano atual
	addi $t5, $t5, 1 # Exclui o ano inicial da contagem (intervalo aberto)
	j continua
	
maior_ano:
	# $t1 é o maior ano, $t0 é o menor
	move $t3, $t1 # $t3 = maior ano
	move $t4, $t0 # $t4 = menor ano
	move $t5, $t4 # $t5 = ano atual
	addi $t5, $t5, 1 # Exclui o ano inicial da contagem (intervalo aberto)
	
continua:
	# Calcula a diferença entre os anos
	sub $t2, $t3, $t4
	bgt $t2, 1000, maior_mil # Se diferença > 1000, exibe erro e reinicia
	beqz $t2, msg_anos_iguais # Se diferença == 0, os anos são iguais
	li $t6, 0 # Inicializa o contador de bissextos em 0
	j comeco_loop
	
maior_mil:
	# Exibe mensagem de erro e volta ao início
	li $v0, 4
	la $a0, fora_intervalo
	syscall
	j main
	
msg_anos_iguais:
	li $v0, 4
	la $a0, anos_iguais
	syscall
	li $v0, 10
	syscall

comeco_loop:
	# Se o ano atual ultrapassou o maior ano, encerra o loop (intervalo aberto)
	bge $t5, $t3, fim
	
verifica_div4:
	# Verifica se o ano atual é divisível por 4
	li $t7, 4
	div $t5, $t7
	mfhi $t8
	bnez $t8, proximo_ano # Resto != 0: não é divisível por 4, não é bissexto
	
verifica_div100:
	# Verifica se o ano atual é divisível por 100
	li $t7, 100
	div $t5, $t7
	mfhi $t8
	beqz $t8, verifica_div400 # Resto == 0: divivísel por 100, precisa testar 400
	j eh_bissexto		  # Resto !: divisível por 4, mas não por 100, é bissexto

verifica_div400:
	# Verifica se o ano é divisível por 400
	li $t7, 400
	div $t5, $t7
	mfhi $t8
	beqz $t8, eh_bissexto # Resto == 0: divisível por 400, é bissexto
	j proximo_ano	      # Resto != 0: divisível por 100, mas não por 400, não é bissexto
	
eh_bissexto:
	addi $t6, $t6, 1 # Incrementa o contador de anos bissextos
	
proximo_ano:
	addi $t5, $t5, 1 # Avança para o próximo ano
	j comeco_loop
	
fim:
	# Imprime a mensagem com o resultado
	li $v0, 4
	la $a0, qtd_bissextos
	syscall
	
	# Imprime o valor do contador
	move $a0, $t6
	li $v0, 1
	syscall