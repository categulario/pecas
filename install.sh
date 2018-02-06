#!/bin/bash

# Menciona dónde fue descargado Pecas
echo "----------------------------------"
echo "=> Pecas se ha descargado en $PWD."

# Para obtener la ruta absoluta del repositorio; viene de http://stackoverflow.com/questions/59895/can-a-bash-script-tell-which-directory-it-is-stored-in
SCRIPT_PATH="${BASH_SOURCE[0]}";
if ([ -h "${SCRIPT_PATH}" ]) then
    while([ -h "${SCRIPT_PATH}" ]) do SCRIPT_PATH=`readlink "${SCRIPT_PATH}"`; done
fi
pushd . > /dev/null
cd `dirname ${SCRIPT_PATH}` > /dev/null
SCRIPT_PATH=`pwd`;
popd  > /dev/null

# Para generar la ruta a la carpeta bin
SCRIPT_PATH="${SCRIPT_PATH}/bin"

# Sustituye los espacios en la ruta
space="\\ "
SCRIPT_PATH=${SCRIPT_PATH// /$space}

# Para localizar dónde se encuentra el perfil; viene de https://github.com/NikaZhenya/sexy-bash-prompt/blob/master/install.bash
if [[ -f ~/.bash_profile ]]; then
  profile_script_short="~/.bash_profile"
  profile_script_full=~/.bash_profile
elif [[ -f ~/.bash_login ]]; then
  profile_script_short="~/.bash_login"
  profile_script_full=~/.bash_login
elif [[ -f ~/.profile ]]; then
  profile_script_short="~/.profile"
  profile_script_full=~/.profile
elif [[ -f ~/.bashrc ]]; then
  profile_script_short="~/.bashrc"
  profile_script_full=~/.bashrc
else
  echo "No se encontró archivo de configuración, creando archivo .bash_profile en la carpeta raíz del usuario."
  echo ""
  touch ~/.bash_profile
  profile_script_short="~/.bash_profile"
  profile_script_full=~/.bash_profile
fi

# La condición también viene de https://github.com/NikaZhenya/sexy-bash-prompt/blob/master/install.bash
if ! grep PECAS_ROOT "$profile_script_full" &> /dev/null; then
    echo "" >> $profile_script_full
    echo "# Pecas" >> $profile_script_full
    echo "export PECAS_ROOT=$SCRIPT_PATH" >> $profile_script_full
    echo "export PATH=\$PECAS_ROOT:\$PATH" >> $profile_script_full
    echo "" >> $profile_script_full

    source $profile_script_full

    echo "=> Se han agregado las herramientas de Pecas a $profile_script_short."
else
    echo "=> Al parecer ya se han agregado las herramientas de Pecas a $profile_script_short."
fi

# Para obtener la ruta absoluta del repositorio; viene de http://stackoverflow.com/questions/59895/can-a-bash-script-tell-which-directory-it-is-stored-in
SCRIPT_PATH="${BASH_SOURCE[0]}";
if ([ -h "${SCRIPT_PATH}" ]) then
    while([ -h "${SCRIPT_PATH}" ]) do SCRIPT_PATH=`readlink "${SCRIPT_PATH}"`; done
fi
pushd . > /dev/null
cd `dirname ${SCRIPT_PATH}` > /dev/null
SCRIPT_PATH=`pwd`;
popd  > /dev/null

# Para generar la ruta a la carpeta bin
SCRIPT_PATH="${SCRIPT_PATH}/src/alien/epubcheck/bin"

# Sustituye los espacios en la ruta
space="\\ "
SCRIPT_PATH=${SCRIPT_PATH// /$space}

# La condición también viene de https://github.com/NikaZhenya/sexy-bash-prompt/blob/master/install.bash
if ! grep EPUBCHECK_ROOT "$profile_script_full" &> /dev/null; then
    echo "# EpubCheck" >> $profile_script_full
    echo "export EPUBCHECK_ROOT=$SCRIPT_PATH" >> $profile_script_full
    echo "export PATH=\$EPUBCHECK_ROOT:\$PATH" >> $profile_script_full
    echo "" >> $profile_script_full

    source $profile_script_full

    echo "=> Se ha agregado EpubCheck a $profile_script_short."
else
    echo "=> Al parecer ya se ha agregado EpubCheck a $profile_script_short."
fi

# Fin, lo ideal es que fuera automático
echo "   => Usa «pc-doctor» para ver el estado de Pecas y sus dependencias."
echo "   => Si no tienes acceso a Pecas, usa «source $profile_script_short»."
