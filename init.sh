# script para rodar a aplicacao caso ela esteja ja instalada
#Para rodar: chmod u+x init.sh && ./init.sh
eval $(opam env) &&

gnome-terminal -e "bash -c 'cd ~/grew/grew_match && python -m http.server'" &&

gnome-terminal -e "bash -c 'cd ~/grew/grew_match_back && make test.opt'" &&

echo '
# French (teste)
http://0.0.0.0:8000/?corpus=UD_French-PUD

# Porttinari
http://0.0.0.0:8000/?corpus=Porttinari

# Dante
http://0.0.0.0:8000/?corpus=Dante

'

