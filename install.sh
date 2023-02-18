# passo a passo: https://grew.fr/grew_match/install/

#Para rodar: chmod u+x install.sh && ./install.sh

#diretorio que armazenara a aplicacao
DIR='/home/semcovici'

#diretorio onde esta o Grew_scripts/
DIRSetup='/home/semcovici/grew_match_setup'

# Requisitos: Pacman

cd $DIR &&
mkdir grew/ &&

# Step 1: Install the webpage
cd grew/ &&
git clone https://gitlab.inria.fr/grew/grew_match.git &&


# Step 2: Start an http server (in another terminal)
#gnome-terminal -e "bash -c 'cd ~ && cd grew/grew_match && python -m http.server'" &&

# Step 3: Install the backend

# install grew
# Step 1: Install opam
sudo pacman -S opam wget m4 unzip  curl bubblewrap && # falta librsvg2-bin
# Step 2: Setup opam
opam init &&
# opam switch create 4.14.1 4.14.1 && (comentado pq da erro se ja estiver nessa ver)
eval $(opam env --switch=4.14.1) &&
opam remote add grew "http://opam.grew.fr" &&
# Step 3: Install the Grew software
opam install grew &&

opam install ssl.0.5.9  && # force the version number, 0.5.10 is broken
opam install ocsipersist-dbm &&
opam install libcaml-dep2pict fileutils &&
opam install libcaml-grew &&
opam install eliom &&

cd $DIR/grew/ &&
git clone https://gitlab.inria.fr/grew/grew_match_back.git &&
mkdir -p  $DIR/grew/grew_match_back/log &&


# Step 4: configure the corpora

cd $DIR/grew/ &&
git clone https://github.com/UniversalDependencies/UD_French-PUD.git &&

mkdir Dante && mkdir Porttinari &&
cp $DIRSetup/corpora/dante.conllu $DIR/grew/Dante/dante.conllu &&
cp $DIRSetup/corpora/porttinari.conllu $DIR/grew/Porttinari/porttinari.conllu &&

# Step 4-1: describe the corpora

mkdir -p $DIR/grew/grew_match_back/corpora &&

cd $DIR/grew/grew_match_back/corpora &&

DIRFrench="$DIR/grew/UD_French-PUD"

echo '{
  "corpora": [{
    "id": "UD_French-PUD",
    "config": "sud",
    "directory": "'$DIR'/grew/UD_French-PUD"
  }]
}
' > "french.json"

echo '{
    "corpora": [{
      "id": "Dante",
      "config": "sud",
      "directory": "'$DIR'/grew/Dante"
    }]
  }
' > "dante.json"

echo '{
    "corpora": [{
      "id": "Porttinari",
      "config": "sud",
      "directory": "'$DIR'/grew/Porttinari"
    }]
  }
' > "porttinari.json"


# Step 4-2: interface description

cd $DIR/grew/grew_match/corpora &&

echo '{
  "backend_server": "http://localhost:8899/",
  "default": "Porttinari",
  "groups": [
    {
      "id": "French",
      "name": "French",
      "mode": "syntax",
      "style": "single",
      "corpora": [
        {
          "id": "UD_French-PUD"
        }
      ]
    },
    {
      "id": "Porttinari",
      "name": "Porttinari",
      "mode": "syntax",
      "style": "single",
      "corpora": [
        {
          "id": "Porttinari"
        }
      ]
    },
    {
      "id": "Dante",
      "name": "Dante",
      "mode": "syntax",
      "style": "single",
      "corpora": [
        {
          "id": "Dante"
        }
      ]
    }
  ]
}
' > "config.json"

# Step 4-3

cd $DIR/grew/grew_match_back &&
# rm gmb.conf.in &&

echo '
%%% This is the template for your configuration file. The %%VALUES%% below are
%%% taken from the Makefile to generate the actual configuration files.
%%% This comment will disappear.
<!-- %%WARNING%% -->
<ocsigen>
  <server>
    <port>%%PORT%%</port>
    %%% Only set for running, not for testing
    %%USERGROUP%%
    <logdir>%%LOGDIR%%</logdir>
    <datadir>%%DATADIR%%</datadir>
    <charset>utf-8</charset>
    %%% Only set when debugging
    %%DEBUGMODE%%
    <commandpipe>%%CMDPIPE%%</commandpipe>
    <extension findlib-package="ocsigenserver.ext.cors"/>
    <extension findlib-package="ocsigenserver.ext.staticmod"/>
    <extension findlib-package="ocsipersist.%%PERSISTENT_DATA_BACKEND%%"/>
    <extension findlib-package="eliom.server">
      <ignoredgetparams regexp="utm_[a-z]*|[a-z]*clid|li_fat_id"/>
    </extension>
    %%% This will include the packages defined as SERVER_PACKAGES in your Makefile:
    %%PACKAGES%%
    <host hostfilter="*">
      <static dir="%%STATICDIR%%" />
      <static dir="%%ELIOMSTATICDIR%%" />
      <eliommodule module="%%LIBDIR%%/%%PROJECT_NAME%%.cma">
          <log>'$DIR'/grew/grew_match_back/log</log>
          <extern>'$DIR'/grew/grew_match_back/static</extern>
          <corpora>'$DIR'/grew/grew_match_back/corpora</corpora>
          <config>'$DIR'/grew/grew_match/corpora/config.json</config>
      </eliommodule>
      <eliom/>
      <cors/>
    </host>
  </server>
</ocsigen>
' > "gmb.conf.in"

# Step 5: compile the corpora
cd ~ &&
grew compile -i $DIR/grew/grew_match_back/corpora/french.json &&
grew compile -grew_match_server $DOCUMENT_ROOT/grew_match/meta -i $DIR/grew/grew_match_back/corpora/french.json &&


# Porttinari
grew compile -i $DIR/grew/grew_match_back/corpora/porttinari.json && grew compile -grew_match_server $DOCUMENT_ROOT/grew_match/meta -i $DIR/grew/grew_match_back/corpora/porttinari.json &&

# Dante
grew compile -i $DIR/grew/grew_match_back/corpora/dante.json && grew compile -grew_match_server $DOCUMENT_ROOT/grew_match/meta -i $DIR/grew/grew_match_back/corpora/dante.json &&


# Start:
cd $DIRSetup &&
chmod u+x init.sh && ./init.sh

