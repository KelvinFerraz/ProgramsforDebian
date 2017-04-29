#!/bin/bash

	#######################################################################################################
	#                                                                                                     #
	#          SCRIPT PARA AGILIZAR PROCESSOS DE ATUALIZAÇÕES E INSTALAÇÕES NO DEBIAN 8 JESSIE            #
	#					                           												          #
	#                   DESENVOLVIDO POR Kelvin Ferraz (kelvinferrazsilva@gmail.com)                      #
	#							        Edit: 27 - ABR - 2017										      #
	#                  												 								      #
	#######################################################################################################
	#																								      #
	# 																							          #
	#  ___   _____   ___   _   _    ___   _____      ___    ___     ___    ___   ___   ___   ___   _____  #
	# / __| |_   _| | _ \ | | | |  / __| |_   _|    / _ \  | __|   / __|  / __| | _ \ |_ _| | _ \ |_   _| #
	# \__ \   | |   |   / | |_| | | (__    | |     | (_) | | _|    \__ \ | (__  |   /  | |  |  _/   | |   #
	# |___/   |_|   |_|_\  \___/   \___|   |_|      \___/  |_|     |___/  \___| |_|_\ |___| |_|     |_|   #
	#                                                                                                     #
	#																									  #
	#######################################################################################################
	#																									  #
	#			 +---------------------+                    +-------------+								  #
	#			 | Verify if is a Root |      IF NOT        |    ERROR    | 							  #
	#			 +---------------------+--------------------+-------------+								  #
	#						|																			  #
	#					  IF YES																		  #
	#						|																			  #
	#			 +---------------------+	  			    +-------------+								  #
	#			 |   Test Connection   |  	  IF NOT 	    |    ERROR    |								  #
	#			 +---------------------+--------------------+-------------+								  #
	#						|																			  #
	#					  IF YES																		  #
	#						|              																  #
	#			 +---------------------+			+---------------------+			     +-------------+  #
	#			 |   Start a Script    |			| Verify dependencies |   IF NOT	 |    ERROR    |  #
	#			 +---------------------+------------+---------------------+--------------+-------------+  #
	#														  |											  #
	#													 IF INSTALLED									  #
	#														  |											  #
	#												+---------------------+								  #
	#	                                            |       Begin         |                               #
	#												+---------------------+                               #
	#   																								  #
	#######################################################################################################

#fullscreen-terminal
#printf '\e[8;600;800t'


#Create file log
LOGFILE="/var/log/${0##*/}".log
# Habilita log copiando a saída padrão para o arquivo LOGFILE
exec 1> >(tee -a "$LOGFILE")
# faz o mesmo para a saída de ERROS
exec 2>&1



#Check if its root
CheckisROOT(){
	if [ "$(id -u)" != "0" ]; then
		echo
		echo "Voce deve executar este script como root! "
	else

		TestConnection

	fi #Check if it's root
}

#Test Connection
TestConnection(){
	clear
	echo "Testing Connection...."
	sleep 2
	clear

	wget -q --tries=10 --timeout=20 --spider http://www.google.com.br

		if [[ $? -eq 0 ]]; then

			echo "Connection OK"
			sleep 2
			clear

			Begin

		else
			echo "Connection Error!"
			echo "Check the connection or configuration"

			exit
		fi


}

#Start Script
Begin(){

	if [ -e /tmp/script.ok ]; then

		InstallingPrograms


	else

		echo "Iniciando o Script...."
		sleep 2

		##Backup do Sources.list
		#cd /etc/apt/
		#mv /etc/apt/sources.list /etc/apt/sources.list.bkp
		#touch /etc/apt/sources.list


		#if [ -e sources.list.bkp ]; then

			#echo "Backup do sources.list realizado com sucesso!"
		#else
			#echo "Verique se foi gerado o arquivo de backup do sourcesl.list"
			#read
		#fi

		##Adicionando linhas no repositorio

		#echo "
		##REPOSITORIOS BASICOS DO DEBIAN 8

		#deb http://ftp.br.debian.org/debian jessie main contrib non-free
		#deb-src http://ftp.br.debian.org/debian jessie main contrib non-free

		#deb http://security.debian.org/ jessie/updates main contrib non-free
		#deb-src http://security.debian.org/ jessie/updates main contrib non-free

		#deb http://ftp.br.debian.org/debian/ jessie-updates main contrib non-free
		#deb-src http://ftp.br.debian.org/debian/ jessie-updates main contrib non-free

		##Multimedia
		#deb http://www.deb-multimedia.org jessie main non-free
		#deb-src http://www.deb-multimedia.org jessie main non-free

		##BackPorts
		#deb http://ftp.br.debian.org/debian/ jessie-backports main contrib non-free" > /etc/apt/sources.list


		#Update Repository
		debconf-apt-progress -- apt-get update

		#Variable receives packet
		packet=$( dpkg --get-selections | grep dialog )

		if [ -n "$packet" ]; then

			echo "Paconte instalado!"
			echo

			#ScriptOk
			touch /tmp/script.ok

			InstallingPrograms

		else
			echo
			echo "Instalando Dependencias..."
			sleep 2

			debconf-apt-progress -- apt-get install dialog


			if [ -n $packet ]; then

				clear
				echo "Dependencias Instaladas com Sucesso!"

				#ScriptOk
				touch /tmp/script.ok

				InstallingPrograms

			else

				clear
				echo " Pacote necessário: dialog  "
				exit
			fi

		fi

	fi #scriptopen
}

InstallingPrograms(){

 Option=$( dialog --backtitle 'Programs for Debian | Viva o Linux' --stdout --menu 'MENU PRINCIPAL:' \
		0 0 0                  \
		1 'Programas DevOps'   \
		2 'Plug-ins'           \
		3 'Programas Design'   \
		4 'Audio e video'      \
		5 'Sair')

		case $Option in
			1) ProgramsDevops ;;
			2) Plugins ;;
			3) ProgramsDesign ;;
			4) Backup ;;
			5) exit ;;
		esac
}

ProgramsDevops(){

	  Option=$(dialog --backtitle 'Viva o Linux | Programs for Debian' --stdout --checklist 'Escolha sua IDE:' 0 0 0 \
		Atom		 'IDE HTML,PYTHON, CSS'     on\
		Bluefish     'IDE HTML & CSS'          off\
		Codeblocks   'IDE C,C++,Assembly'  	   off\
		Geany        'IDE Completa'            off\
        Sublime-text 'IDE PHP,CSS,HTML (V3.1)' off)

	#To convert lowercase to uppercase
	OptionDev=$(echo "$Option" | tr 'A-Z' 'a-z')
	
	
	#Sublime-Text Installation
	if echo "$OptionDev" | egrep 'sublime-text' > /dev/null ; then

		#32 or 64 bit?
		arq=$( file /bin/bash | cut -d' ' -f3 )

		#condiction 32 or 64 bit
	     if [ $arq = '64-bit' ]; then
		     cd /tmp/
		     rm -rf /tmp/*.deb
		     rm -rf /tmp/*.deb.*

		     SublimeText64="https://download.sublimetext.com/sublime-text_build-3126_amd64.deb"
		     wget "$SublimeText64" 2>&1 | \
			 stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | \
			 dialog --backtitle 'Downloda do Sublime Text V3.126' --gauge "Download Sublime-Text 64-Bit" 0 50

		     #Installation packege
		     clear
		     dpkg -i sublime-text_build-3126_amd64.deb
		     apt-get install -f

	     elif [ $arq = '32-bit' ]; then
		     cd /tmp/
		     rm -rf /tmp/*.deb
		     rm -rf /tmp/*.deb.*

		     SublimeText32="https://download.sublimetext.com/sublime-text_build-3126_i386.deb"
		     wget "$SublimeText32" 2>&1 | \
			 stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | \
			 dialog --backtitle 'Downloda do Sublime Text V3.126' --gauge "Download Sublime-Text 32-Bit" 0 50

		     #Installation packege                     br
		     clear
		     dpkg -i sublime-text_build-3126_i386.deb
		     apt-get install -f
	     fi

	else

	    sleep 0.01

	fi


	#condiction if variable is a NULL
	if [[ -z $OptionDev ]]; then

		InstallingPrograms

	else
	
		#Installation of the chosen packages
		debconf-apt-progress -- apt-get install $OptionDev -y
		
		InstallingPrograms
		
	fi

	

}


CheckisROOT
