# Verifica si ya se tiene Xcode Command Line Tools, de lo contrario lo instala
if hash make 2>/dev/null; then

	# Verifica si Hombrew está instalado
	if hash brew 2>/dev/null; then
		echo "Homebrew ha sido detectado, continuando con las instalaciones..."
	else
		echo "Homebrew no ha sido detectado, se procederá con su instalación para después instalar el resto de los programas..."
		# Homebrew
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi

	# Git
	brew install git

	# Wget
	brew install wget

	# Ruby
	brew install ruby

	# Pandoc
	brew install pandoc

	# Ghostscript
	brew install ghostscript

	# Tesseract
	brew install tesseract --with-all-languages

	# Scan Tailor
	brew install homebrew/x11/scantailor

	# Pecas
	if [[ -d ~/Repositorios/Pecas ]]; then
		echo "No se pudo instalar Pecas porque ya existe el directorio ~/Repositorios/Pecas"
	else
		if [[ -d ~/Repositorios ]]; then
			cd ~/Repositorios
		else
			cd ~ && mkdir Repositorios && cd Repositorios
			echo "Se ha creado la carpeta «Repositorios» para contener Pecas."			
		fi

		git clone https://github.com/ColectivoPerroTriste/Pecas.git && cd Pecas && sh instalar.sh		
	fi

	# Geany, el DMG se guarda en el escritorio, hay que abrirlo y arrastrarlo a «Aplicaciones»
	cd ~/Desktop && wget http://download.geany.org/geany-1.30.1_osx.dmg && cd ..
	echo "Geany ha sido descargado en el escritorio, manualmente se tiene que mover la aplicación a la carpeta «Aplicaciones»."

	# Sexy Bash Prompt
	if [[ -f ~/.bashrc ]]; then
		cd /tmp && git clone --depth 1 https://github.com/NikaZhenya/sexy-bash-prompt && cd sexy-bash-prompt && make install
	else
		touch ~/.bashrc && cd /tmp && git clone --depth 1 https://github.com/NikaZhenya/sexy-bash-prompt && cd sexy-bash-prompt && make install
	fi
	echo "Cierra y abre la terminal, o ingresa «source ~/.bashrc» para que los cambios tomen efecto."
	
	# Fin
	echo "¡Instalaciones completadas!"
else
	echo "Xcode Command Line Tools es necesario, procediendo con su instalación..."
	echo "Si no es posible instalar, use la App Store para instalar Xcode, para luego abrirlo y aceptar los términos de licencia."
	echo "Una vez aceptados los términos, vuélvase a ejecutar este script."
	xcode-select --install
fi
