#!/bin/bash

	#######################################################################################################
	#                                                                                                     #
	#          SCRIPT PARA AGILIZAR PROCESSOS DE ATUALIZAÇÕES E INSTALAÇÕES NO DEBIAN 8 JESSIE            #
	#					                           				      #
	#                   DESENVOLVIDO POR Kelvin Ferraz (kelvinferrazsilva@gmail.com)                      #
	#					Edit: 02 - MAI - 2017		                              #
	#                  										      #
	#######################################################################################################
	#												      #
	# 												      #
	#  ___   _____   ___   _   _    ___   _____      ___    ___     ___    ___   ___   ___   ___   _____  #
	# / __| |_   _| | _ \ | | | |  / __| |_   _|    / _ \  | __|   / __|  / __| | _ \ |_ _| | _ \ |_   _| #
	# \__ \   | |   |   / | |_| | | (__    | |     | (_) | | _|    \__ \ | (__  |   /  | |  |  _/   | |   #
	# |___/   |_|   |_|_\  \___/   \___|   |_|      \___/  |_|     |___/  \___| |_|_\ |___| |_|     |_|   #
	#                                                                                                     #
	#												      #
	#######################################################################################################
	#												      #
	#			 +---------------------+                    +-------------+		      #
	#			 | Verify if is a Root |      IF NOT        |    ERROR    | 		      #
	#			 +---------------------+--------------------+-------------+          	      #
	#				    |								      #
	#			         IF YES								      #
	#				    |								      #
	#			 +---------------------+	  		    +-------------+	      #
	#			 |   Test Connection   |  	  IF NOT 	    |    ERROR    |           #
	#			 +---------------------+----------------------------+-------------+	      #
	#				    |								      #
	#				 IF YES							              #
	#				    |              						      #
	#		+---------------------+     +---------------------+	         +-------------+      #
	#		|   Start a Script    |	    | Verify dependencies |   IF NOT	 |    ERROR    |      #
	#		+---------------------+------------+---------------------+-------+-------------+      #
	#	    		                             |						      #
	#		                                IF INSTALLED					      #
	#			                             |						      #
	#					    +---------------------+				      #
	#	               			    |       Begin         |                                   #
	#					    +---------------------+                                   #
	#   						     						      #
	#######################################################################################################

clear

#Full-Screen Option
StartFullScreen(){
echo "Deseja executar em fullscreen?"
echo "Entre com a opcao [S-N]" 
read opcaofullscreen


	if [ "$opcaofullscreen" = "s" ] || [ "$opcaofullscreen" = "S" ]; then
														 
		fullscreen-terminal
		printf '\e[8;600;800t'
		
		CheckisROOT


	elif [ "$opcaofullscreen" = "n" ] || [ "$opcaofullscreen" = "N" ]; then
		
		CheckisROOT			
	else
	
		clear 
		echo "Opcao Invalida! Digite S ou N"
		StartFullScreen
	
	fi 
}



#Create file log
LOGFILE="/var/log/${0##*/}".log
# Enables logging by copying the default output to the LOGFILE file
exec 1> >(tee -a "$LOGFILE")
# Does the same for ERROR output
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

		#Backup do Sources.list
		cd /etc/apt/
		mv /etc/apt/sources.list /etc/apt/sources.list.bkp
		touch /etc/apt/sources.list


		if [ -e sources.list.bkp ]; then

			echo "Backup do sources.list realizado com sucesso!"
		else
			echo "Verique se foi gerado o arquivo de backup do sourcesl.list"
			read
		fi

		#Adicionando linhas no repositorio

		echo "
		#REPOSITORIOS BASICOS DO DEBIAN 8

		deb http://ftp.br.debian.org/debian jessie main contrib non-free
		deb-src http://ftp.br.debian.org/debian jessie main contrib non-free

		deb http://security.debian.org/ jessie/updates main contrib non-free
		deb-src http://security.debian.org/ jessie/updates main contrib non-free

		deb http://ftp.br.debian.org/debian/ jessie-updates main contrib non-free
		deb-src http://ftp.br.debian.org/debian/ jessie-updates main contrib non-free

		#Multimedia
		deb http://www.deb-multimedia.org jessie main non-free
		deb-src http://www.deb-multimedia.org jessie main non-free

		#BackPorts
		deb http://ftp.br.debian.org/debian/ jessie-backports main contrib non-free" > /etc/apt/sources.list


		#Update Repository
		debconf-apt-progress -- apt-get update
		debconf-apt-progress -- apt-get install debian-keyring  -y


		#Repository Java		
		echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list
		echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
		apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886

		
		#Fix package in pub multimedia key
		gpg --keyring /usr/share/keyrings/debian-keyring.gpg -a --export 5C808C2B65558117 | apt-key add -

		
		#Update Repository
		debconf-apt-progress -- apt-get update
		debconf-apt-progress -- apt-get upgrade -y
		
		
		#Variable receives packet (Dependencies needed to run the script)
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
				echo " Pacote necessário: O script depende: dialog  "
				exit
			fi

		fi

	fi
}

#Menu Install Programs
InstallingPrograms(){

 Option=$( dialog --backtitle 'Programs for Debian | Viva o Linux' --stdout --menu 'MENU PRINCIPAL:' \
		0 0 0                       \
		1 'Programas DevOps'        \
		2 'Plug-ins'                \
		3 'Programas Design'        \
		4 'Players (Audio e Video)' \
		5 'Programas Internet'      \
		6 'Sair')

		case $Option in
			1) ProgramsDevops ;;
			2) Plugins ;;
			3) ProgramsDesign ;;
			4) ProgramsPlayers ;;
			5) ProgramsInternet ;;
			6) Exit ;;
		esac
}

#Packet of DevOps
ProgramsDevops(){

	  Option=$(dialog --backtitle 'Viva o Linux | Packet for Development' --stdout --checklist 'Escolha sua IDE:' 0 0 0 \
		Atom		 'IDE HTML,PYTHON, CSS'     on\
		Bluefish     'IDE HTML & CSS'          off\
		Codeblocks   'IDE C,C++,Assembly'  	   off\
		Eclipse		 'IDE Java,C,C++,HTML'     off\
		Geany        'IDE Bash,C,'            off\
        Sublime-text 'IDE PHP,CSS,HTML (V3.1)' off)


	#case cancel button is selected back to Programs Menu
	if [ $? -eq 1 ]; then
	
		InstallingPrograms
	
	fi
	
	#To convert lowercase to uppercase
	OptionDev=$(echo "$Option" | tr 'A-Z' 'a-z')	
	
	#Sublime-Text Installation
	packetsublime=$( dpkg --get-selections | grep sublime-text )	
	
	#Atom Installation
	packetatom=$( which -a atom )
	
	
	
	if [[ -z $OptionDev ]]; then

		InstallingPrograms	

	else
	
		#Instalation Atom
		if echo "$OptionDev" | egrep 'atom' > /dev/null ; then
		
			if [ -n "$packetatom" ]; then

				dialog --backtitle 'Instalacao do Atom'\
				   --title "AVISO"\
				   --msgbox "O Sistema já possui o Atom"  10 23 \
	   
				
			else		
			
		
				 cd /tmp/
				 rm -rf /tmp/*.deb
				 rm -rf /tmp/*.deb.*

				 Atom="https://atom.io/download/deb"
				 wget "$Atom" 2>&1 | \
				 stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | \
				 dialog --backtitle 'Atom' --gauge "Download Atom" 0 50

				 #Installation packege
				 clear
				 debconf-apt-progress -- apt-get install git -y
				 dpkg -i deb				  
				 apt-get install -f -y
				
			fi
		fi
		
			if echo "$OptionDev" | egrep 'sublime-text' > /dev/null ; then	
				
				if [ -n "$packetsublime" ]; then
					
						dialog --backtitle 'Instalacao do Sublime-Text 3.1'\
							   --title "AVISO"\
							   --msgbox "O Sistema já possui o Sublime-Text"  10 23 \
						   
				else
		
				
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

						 #Installation packege
						 clear
						 dpkg -i sublime-text_build-3126_i386.deb
						 apt-get install -f -y
					fi
											
				fi
			fi
			
		#Installation of the chosen packages
		debconf-apt-progress -- apt-get install $OptionDev -y

		dialog --backtitle 'Instalacao de pacotes'\
			   --title "AVISO"\
		       --msgbox "Os pacotes: $OptionDev  foram instalados!"  10 30 \

		InstallingPrograms
	
	fi

	
	
	

}

#Packet of Plugins
Plugins(){
	Option=$(dialog --backtitle 'Viva o Linux | Plugins' --stdout --checklist 'Escolha os Plugins:' 0 0 0 \
		Msttcorefonts 			'Fontes MS'        				 		 on\
		Oracle-java8-installer  'Java 8'  	       				   		off\
		Multimedia	 			'Principais plugins de audio e video'   off)
	
	#case cancel button is selected back to Programs Menu
	if [ $? -eq 1 ]; then
	
		InstallingPrograms
	
	fi

	#To convert lowercase to uppercase
	OptionPlugin=$(echo "$Option" | tr 'A-Z' 'a-z')

	if [[ -z $OptionPlugin ]]; then

		InstallingPrograms	

	else
	
		#Instalation Multimedia
		if echo "$OptionPlugin" | egrep 'multimedia' > /dev/null ; then
	
			sleep 0.1

		else

			debconf-apt-progress -- apt-get install gstreamer0.10-fluendo-mp3 gstreamer0.10-plugins-really-bad ffmpeg sox twolame vorbis-tools lame faad -y
			debconf-apt-progress -- apt-get install gstreamer0.10-plugins-bad -y
			
		fi
			

		
			#Installation of the chosen packages
			debconf-apt-progress -- apt-get install $OptionPlugin -y

			dialog --backtitle 'Instalacao de pacotes'\
				   --title "AVISO"\
				   --msgbox "Os pacotes: $OptionPlugin foram instalados!"  10 30 \

			InstallingPrograms	
	fi



}

#Packet of Desing Application
ProgramsDesign(){

	Option=$(dialog --backtitle 'Viva o Linux | Design' --stdout --checklist 'Escolha seu Programa:' 0 0 0 \
		Blender	'Modelador 3D' 	            on\
		Gimp    'Editor de Imagem'         off\
		Inkscape 'Vetorização de Imagem'   off)
	
	#case cancel button is selected back to Programs Menu
	if [ $? -eq 1 ]; then
	
		InstallingPrograms
	
	fi

	
	#To convert lowercase to uppercase
	OptionDesing=$(echo "$Option" | tr 'A-Z' 'a-z')
	
	
	if [[ -z $OptionDesing ]]; then

		InstallingPrograms	

	else
					
		#Installation of the chosen packages
		debconf-apt-progress -- apt-get install $OptionDesing -y

		dialog --backtitle 'Instalacao de pacotes'\
			   --title "AVISO"\
			   --msgbox "Os pacotes: $OptionDesing foram instalados!"  10 30 \
		
		InstallingPrograms
	fi
}

#Packet of Players
ProgramsPlayers(){

	Option=$(dialog --backtitle 'Viva o Linux | Players Audio e Video' --stdout --checklist 'Escolha seu Player' 0 0 0 \
		Amarok         'Player de Video base em KDE'                 on\
		Audacious	   'Player de Audio interface do Winamp'        off\
		Clementine     'PLayer de Audio Completo'                   off\
		Kodi           'Media Center e Player de Audio/Video'       off\
		Qmmp           'Player de Audio interface do Winamp'        off\
		Smplayer       'Player de Video'                            off\
		Spotify-client 'Player de Audio Biblioteca Online'          off\
		Vlc            'Player de Vídeos com Recurso de Gravação'   off)
		
	
	
	#case cancel button is selected back to Programs Menu
	if [ $? -eq 1 ]; then
	
		InstallingPrograms
	
	fi
	
	
	#To convert lowercase to uppercase
	OptionPlayers=$(echo "$Option" | tr 'A-Z' 'a-z')
	
	#if exist packet spotify
	packetspotify=$(dpkg --get-selections | grep spotify-client)

	
	
	if [[ -z $OptionPlayers ]]; then

		InstallingPrograms	

	else
	
		#Instalation Spotfy
		if echo "$OptionPlayers" | egrep 'spotify-client' > /dev/null ; then
	
			if [ -n "$packetspotify" ]; then
					
				dialog --backtitle 'Instalacao do Spotify'\
					   --title "AVISO"\
					   --msgbox "O Sistema já possui o Spotfy"  10 23 \
						   
			else

				# 1. Add the Spotify repository signing key to be able to verify downloaded packages
				apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886

				# 2. Add the Spotify repository
				echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list

				# 3. Update list of available packages
				debconf-apt-progress -- apt-get update

				# 4. Install Spotify
				#debconf-apt-progress -- apt-get install spotify-client -y
			
			fi
		fi
	
	
		#Installation of the chosen packages
		debconf-apt-progress -- apt-get install $OptionPlayers -y

		dialog --backtitle 'Instalacao de pacotes'\
			   --title "AVISO"\
			   --msgbox "Os pacotes: $OptionPlayers foram instalados!" 10 30 \
		
		InstallingPrograms
	
	fi
		


}

#Packet of Internet
ProgramsInternet(){


	Option=$(dialog --backtitle 'Viva o Linux | Players Audio e Video' --stdout --checklist 'Escolha seu Programa:' 0 0 0 \
		Qbittorrent 'Gerenciador Torrent'   	    on\
		Skype       'Chat de Mensagem Voz e Video' off\
		Teamviewer  'Acesso remoto'                off)
		
	##case cancel button is selected back to Programs Menu
	if [ $? -eq 1 ]; then
	
		InstallingPrograms
	
	fi
	
	#To convert lowercase to uppercase
	OptionInternet=$(echo "$Option" | tr 'A-Z' 'a-z')
	
	#if exist teamviwer
	packetteamviewer=$(which -a teamviewer)
	packetskype=$(which -a skypeforlinux)
	
	if [[ -z $OptionInternet ]]; then

		InstallingPrograms	

	else
		
				
		#Instalation Team Viwer
		if echo "$OptionInternet" | egrep 'teamviewer' > /dev/null ; then
	
			if [ -n "$packetteamviewer" ]; then
					
				dialog --backtitle 'Instalacao do Teamviewer 12'\
					   --title "AVISO"\
					   --msgbox "O Sistema já possui o Teamviewer 12"  10 23 \
						   
			else
					
				cd /tmp/
				rm -rf /tmp/*.deb
				rm -rf /tmp/*.deb.*
							
				Teamviewer="http://download.teamviewer.com/download/teamviewer_i386.deb"
				wget "$Teamviewer" 2>&1 | \
				stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | \
				dialog --backtitle 'Teamviewer' --gauge "Download Teamviewer" 0 50
			
				dpkg --add-architecture i386
				debconf-apt-progress -- apt-get update
				
				dpkg -i teamviewer_i386.deb
				apt-get install -f -y
			
			fi
		fi
		
		
		#Instalation Skype
		if echo "$OptionInternet" | egrep 'skype' > /dev/null ; then
	
			
			if [ -n "$packetskype" ]; then
					
				dialog --backtitle 'Instalacao do Skype'\
					   --title "AVISO"\
					   --msgbox "O Sistema já possui o Skype"  10 23 \
						   
			else

			
				arq=$( file /bin/bash | cut -d' ' -f3 )

				#condiction 32 or 64 bit
				if [ $arq = '64-bit' ]; then
				
					cd /tmp/
					rm -rf /tmp/*.deb
					rm -rf /tmp/*.deb.*
					
					
					Skype="https://repo.skype.com/latest/skypeforlinux-64.deb"
					wget "$Skype" 2>&1 | \
					stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | \
					dialog --backtitle 'Skype' --gauge "Download Skype" 0 50
			
					dpkg --add-architecture i386			
					debconf-apt-progress -- apt-get update
					
					gpg --keyserver pgpkeys.mit.edu --recv-key 1F3045A5DF7587C3
					gpg -a --export 1F3045A5DF7587C3 | sudo apt-key add -
					debconf-apt-progress -- apt-get update		
					
					dpkg -i skypeforlinux-64.deb				
					apt-get	install -f -y
					
				elif [ $arq = '32-bit' ]; then
				
					cd /tmp/
					rm -rf /tmp/*.deb
					rm -rf /tmp/*.deb.*
					
					
					Skype="wget skype-install.deb http://www.skype.com/go/getskype-linux-deb"
					wget "$Skype" 2>&1 | \
					stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | \
					dialog --backtitle 'Skype' --gauge "Download Skype" 0 50
				
					dpkg --add-architecture i386			
					debconf-apt-progress -- apt-get update
					
					gpg --keyserver pgpkeys.mit.edu --recv-key 1F3045A5DF7587C3
					gpg -a --export 1F3045A5DF7587C3 | sudo apt-key add -
					debconf-apt-progress -- apt-get update		
					
					dpkg -i getskype-linux-deb			
					apt-get	install -f -y
				
				fi
			fi
		
		fi

		
		#Installation of the chosen packages
		debconf-apt-progress -- apt-get install $OptionInternet -y

		dialog --backtitle 'Instalacao de pacotes'\
			   --title "AVISO"\
			   --msgbox "Os pacotes: $OptionInternet  foram instalados!"  10 30 \

		InstallingPrograms

	
	fi


}


Exit(){

	debconf-apt-progress -- apt-get autoremove -y
	exit
}

StartFullScreen
