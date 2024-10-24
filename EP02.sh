#!/bin/bash
##################################################################
# MAC0216 - Técnicas de Programação I (2024)
# EP2 - Programação em Bash
#
# Nome do(a) aluno(a) 1: Fernando Ramos Takara
# NUSP 1: 13782230
#
# Nome do(a) aluno(a) 2:
# NUSP 2:
##################################################################

#Variáveis para navegar pelos diretórios
dir_atual=$(pwd)
dir_dados="/Dados"

function selecionar_arquivo {
    echo Escolha uma opção de arquivo:
    indice="0"
    for i in $(ls "$dir_atual$dir_dados"); do
        indice=$(echo "$indice + 1" | bc)
        echo "$indice) $i"
    done
    echo -n "#? " 
    read arq_indice
    arq_escolhido="$(echo "$(ls "$dir_atual$dir_dados")" |tr '\n' ' ' | cut -d' ' -f$arq_indice)"
    cat $dir_atual$dir_dados/$arq_escolhido > $dir_atual$dir_dados/.csv
    echo +++ Arquivo atual: "$arq_escolhido"
    echo +++ Número de reclamações: "$(wc -l "$dir_atual$dir_dados"/"$arq_escolhido" | cut -d' ' -f1)"
    echo +++++++++++++++++++++++++++++++++++++++
    echo
}

function adicionar_filtro_coluna {
    echo Escolha uma opção de coluna para o filtro:
    indice="0"
    for i in $(head -n +1 $dir_atual$dir_dados"/"$arq_escolhido | tr ' ;' '@ '); do
        indice=$(echo "$indice + 1" | bc)
        echo "$indice) $(echo $i | tr '@' ' ')"
    done
    echo -n "#? "
    read coluna_indice
    coluna_escolhida="$(head -n +1 $dir_atual$dir_dados"/"$arq_escolhido | tr ' ;' '@ ' | cut -d' ' -f$coluna_indice)"
    coluna_escolhida="$(echo $coluna_escolhida | tr '@' ' ')"
    echo
    echo Escolha uma opção de valor para "$coluna_escolhida":
    indice="0"
    for i in $(tail -n +2 $dir_atual$dir_dados"/"$arq_escolhido | cut -d ';' -f$coluna_indice | grep -v '^$' | sort | uniq | tr ' \n' '@ '); do
        indice=$(echo "$indice + 1" | bc)
        echo "$indice) $(echo $i | tr '@' ' ')"
    done
    echo -n "#? "
    read filtro_indice
    filtro_escolhido="$(tail -n +2 $dir_atual$dir_dados"/"$arq_escolhido | cut -d ';' -f$coluna_indice | grep -v '^$' | sort | uniq | tr ' \n' '@ ' | cut -d ' ' -f$filtro_indice)"
    filtro_escolhido=$(echo $filtro_escolhido | tr '@' ' ') 
    echo
    echo +++ Adicionado filtro: "$coluna_escolhida" = "$filtro_escolhido"
    echo +++ Arquivo atual: $arq_escolhido
    grep "$filtro_escolhido" $dir_atual$dir_dados/.csv > $dir_atual$dir_dados/temp.csv
    cat $dir_atual$dir_dados/temp.csv > $dir_atual$dir_dados/.csv
    rm $dir_atual$dir_dados/temp.csv
    filtros_salvos[numero_filtros]=$(echo $coluna_escolhida = $filtro_escolhido | tr ' ' '@')
    numero_filtros=$(echo "$numero_filtros + 1" | bc)
    echo +++ Filtros atuais:
    for i in $(seq $(echo ${#filtros_salvos[@]})); do
        if [ $i != ${#filtros_salvos[@]} ]; then
            i=$(echo "$i - 1" | bc)
            echo -n ${filtros_salvos[$i]} | tr '@' ' '
            echo -n " | "
        else
            i=$(echo "$i - 1" | bc)
            echo ${filtros_salvos[$i]} | tr '@' ' '
        fi 
    done
    echo -n +++ Número de reclamações: 
    echo $(wc -l "$dir_atual$dir_dados/.csv" | cut -d ' ' -f1)
    echo +++++++++++++++++++++++++++++++++++++++
}

function limpar_filtros_colunas {
    filtros_salvos=()
    numero_filtros="0"
    cat $dir_atual$dir_dados/$arq_escolhido > $dir_atual$dir_dados/.csv
    echo +++ Filtros removidos
    echo +++ Arquivo atual: $arq_escolhido
    echo +++ Número de reclamações: "$(wc -l "$dir_atual$dir_dados"/.csv | cut -d' ' -f1)"
    echo +++++++++++++++++++++++++++++++++++++++
}

function mostrar_duracao_media_reclamacao {
    echo "
não implementando
    "
}

function mostrar_ranking_reclamacoes {
    echo "
não implementando
    "
}

function mostrar_reclamacoes {
    echo "
não implementando
    "
}

function sair {
    echo Fim do programa
    echo +++++++++++++++++++++++++++++++++++++++
    exit 0
}

echo "+++++++++++++++++++++++++++++++++++++++
Este programa mostra estatísticas do
Serviço 156 da Prefeitura de São Paulo
+++++++++++++++++++++++++++++++++++++++"


#Se o número de parâmetros for diferente de 0, então baixamos os n URL's com o wget no path_atual/Dados. Além disso, modificamos a codificação do arquivo csv baixado de ISO-8859-1 para UTF+8 com o iconv, deletando o antigo.
if [ $# != 0 ]; then
    wc $1 &> /dev/null || { echo "ERRO: O arquivo "$1" não existe. "; exit 0; } #Caso não ache o programa, o script termina 
    wget -nv -i $1 -P "$dir_atual$dir_dados"
    for i in $(ls "$dir_atual$dir_dados" --time=creation | head -n $(wc $1 -w 2> /dev/null | cut -d' ' -f1) 2> /dev/null); do 
        nome_arq=$(echo $i)
        iconv -f ISO-8859-1 -t UTF8 "$dir_atual$dir_dados"/"$nome_arq" -o "$dir_atual$dir_dados"/temp.csv
        rm "$dir_atual$dir_dados"/"$nome_arq"
        mv "$dir_atual$dir_dados"/temp.csv "$dir_atual$dir_dados"/"$nome_arq"
        if [ -e "$dir_atual$dir_dados"/arquivocompleto.csv ]; then
            tail -n +2 "$dir_atual$dir_dados"/"$nome_arq" >> "$dir_atual$dir_dados"/arquivocompleto.csv
        else
            cat "$dir_atual$dir_dados"/"$nome_arq" >> "$dir_atual$dir_dados"/arquivocompleto.csv
        fi
    done
fi 

#Checa se tem arquivos baixados
if [ ! "$(ls -A "$dir_atual$dir_dados")" ]; then
   echo "ERRO: Não há dados baixados.
Para baixar os dados antes de gerar as estatísticas, use:
  ./ep2_servico156.sh <nome do arquivo com URLs de dados do Serviço 156>"
  exit 0    
fi

rm $dir_atual$dir_dados/.csv
touch $dir_atual$dir_dados/.csv
arq_escolhido="arquivocompleto.csv"
numero_filtros="0"
cat "$dir_atual$dir_dados"/"$arq_escolhido" >> "$dir_atual$dir_dados"/.csv
echo

while [ true ]; do
    echo -n "Escolha uma opção de operação:
1) selecionar_arquivo        4) mostrar_duracao_media_reclamacao   7) sair
2) adicionar_filtro_coluna   5) mostrar_ranking_reclamacoes
3) limpar_filtros_colunas    6) mostrar_reclamacoes
#? "
    read usr_input
    echo
    case $usr_input in
        1 ) selecionar_arquivo;;
        2 ) adicionar_filtro_coluna;;
        3 ) limpar_filtros_colunas;;
        4 ) mostrar_duracao_media_reclamacao;;
        5 ) mostrar_ranking_reclamacoes;;
        6 ) mostrar_reclamacoes;;
        7 ) sair;;
        *) echo "Comando Invalido
+++++++++++++++++++++++++++++++++++++++";;
    esac
done
