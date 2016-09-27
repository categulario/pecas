#!/bin/bash

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
else
  echo "FATAL: archivo de inicialización de usuario no encontrado." 1>&2
  exit 1
fi

# La condición también biene de https://github.com/NikaZhenya/sexy-bash-prompt/blob/master/install.bash
if ! grep PT_HERRAMIENTAS_ROOT "$profile_script_full" &> /dev/null; then
    echo "" >> $profile_script_full
    echo "# Herramientas de Perro Triste" >> $profile_script_full
    echo "export PT_HERRAMIENTAS_ROOT=$SCRIPT_PATH" >> $profile_script_full
    echo "export PATH=\$PT_HERRAMIENTAS_ROOT:\$PATH" >> $profile_script_full
    echo "" >> $profile_script_full

    source $profile_script_full

    echo "Se han agregado las herramientas de Perro Triste a $profile_script_short."
else
    echo "Al parecer ya se han agregado las herramientas de Perro Triste a $profile_script_short."
fi