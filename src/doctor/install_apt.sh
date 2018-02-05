#!/bin/bash 

# Función para obtener respuestas de sí o no
ask() {
	# https://gist.github.com/davejamesmiller/1965569
    # https://djm.me/ask
    local prompt default REPLY

    while true; do

        if [ "${2:-}" = "Y" ]; then
            prompt="Y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi

        # Ask the question (not using "read -p" as it uses stderr not stdout)
        echo -n "$1 [$prompt] "

        # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
        read REPLY </dev/tty

        # Default?
        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi

        # Check if the reply is valid
        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}

instalar() {
	if hash $1 2>/dev/null; then
		echo "$2 ha sido detectado, continuando con las instalaciones..."
	else
		echo "$2 no ha sido detectado, se procederá con su instalación para después instalar el resto de los programas..."
		
		if [ $2 = "Pandoc" ]; then
			cd /tmp && wget https://github.com/jgm/pandoc/releases/download/1.19.2.1/pandoc-1.19.2.1-1-amd64.deb && sudo dpkg -i pandoc-1.19.2.1-1-amd64.deb
		elif [ $2 = "Tesseract" ]; then
			sudo apt install tesseract-ocr && sudo apt install tesseract-ocr-spa
		elif [ $2 = "Pecas" ]; then
			if [ -d ~/Repositorios/Pecas ]; then 
				echo 'No se pudo instalar Pecas porque ya existe el directorio ~/Repositorios/Pecas' 
			else
				if [ -d ~/Repositorios ]; then 
					cd ~/Repositorios
				else 
					cd ~ && mkdir Repositorios && cd Repositorios echo 'Se ha creado la carpeta «Repositorios» para contener Pecas.'
				fi 
				git clone https://github.com/ColectivoPerroTriste/Pecas.git && cd Pecas && bash instalar.sh
			fi
		else
			$3
		fi
	fi
}

# Actualización forzada para encontrar todos los repositorios
sudo apt update

# Git
instalar git "Git" "sudo apt install git"

# Wget
instalar wget "Wget" "sudo apt install wget"

# Ruby
instalar ruby "Ruby" "sudo apt install ruby"

# Pandoc
instalar pandoc "Pandoc"

# Ghostscript
instalar gs "Ghostscript" "sudo apt install ghostscript"

# Tesseract
instalar tesseract "Tesseract"

# Scan Tailor
instalar scantailor "Scan Tailor" "sudo apt install scantailor"

# Pecas
instalar pc-automata "Pecas"

# Sexy Bash Prompt
if ask "¿Quieres instalar Sexy Bash Prompt, un embellecedor del prompt?" Y; then
	if [[ -f ~/.bashrc ]]; then
		cd /tmp && git clone --depth 1 https://github.com/NikaZhenya/sexy-bash-prompt && cd sexy-bash-prompt && make install
	else
		touch ~/.bashrc && cd /tmp && git clone --depth 1 https://github.com/NikaZhenya/sexy-bash-prompt && cd sexy-bash-prompt && make install
	fi
	echo "Cierra y abre la terminal, o ingresa «source ~/.bashrc» para que los cambios tomen efecto."
else
	echo "Sexy Bash Prompt no ha sido instalado."
fi
	
# Fin
echo "¡Instalaciones completadas!"
