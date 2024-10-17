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

dir_atual=$(pwd)
dir_dados="/Dados"

function selecionar_arquivo {
    echo "
não implementando
    "
}

function adicionar_filtro_coluna {
    echo "
não implementando
    "
}

function limpar_filtros_colunas {
    echo "
não implementando
    "
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
    exit 0
}

echo "+++++++++++++++++++++++++++++++++++++++
Este programa mostra estatísticas do
Serviço 156 da Prefeitura de São Paulo
+++++++++++++++++++++++++++++++++++++++"


#Se o número de parâmetros for diferente de 0, então baixamos os n URL's com o wget no path_atual/Dados. Além disso, modificamos a codificação do arquivo csv baixado de ISO-8859-1 para UTF+8 com o iconv, deletando o antigo.
if [ $# != 0 ]; then
    dir_atual=$(pwd)
    dir_dados="/Dados"
    wget -nv -i $1 -P "$dir_atual$dir_dados" || (echo ERRO: O arquivo "$1" não existe. && exit 0)
    wc $1 &> /dev/null || exit 0 #Caso não ache o programa, o script termina 
    for i in $(ls "$dir_atual$dir_dados" | head -n $(wc $1 -w 2> /dev/null | cut -d' ' -f1) 2> /dev/null); do 
        nome_arq=$(echo $i)
        iconv -f ISO-8859-1 -t UTF8 "$dir_atual$dir_dados"/"$nome_arq" -o "$dir_atual$dir_dados"/temp.csv
        rm "$dir_atual$dir_dados"/"$nome_arq"
        mv "$dir_atual$dir_dados"/temp.csv "$dir_atual$dir_dados"/"$nome_arq"
    done
fi  

#Checa se tem arquivos baixados
if [ -z "$(ls -A "$dir_atual$dir_dados" 2>/dev/null)" ]; then
   echo "ERRO: Não há dados baixados.
Para baixar os dados antes de gerar as estatísticas, use:
  ./ep2_servico156.sh <nome do arquivo com URLs de dados do Serviço 156>"
  exit 0    
fi

echo

while [ true ]; do
    echo -n "Escolha uma opção de operação:
1) selecionar_arquivo        4) mostrar_duracao_media_reclamacao   7) sair
2) adicionar_filtro_coluna   5) mostrar_ranking_reclamacoes
3) limpar_filtros_colunas    6) mostrar_reclamacoes
#? "
    read usr_input
    case $usr_input in
        1 ) selecionar_arquivo;;
        2 ) adicionar_filtro_coluna;;
        3 ) limpar_filtros_colunas;;
        4 ) mostrar_duracao_media_reclamacao;;
        5 ) mostrar_ranking_reclamacoes;;
        6 ) mostrar_reclamacoes;;
        7 ) sair;;
        *) echo "
Comando Invalido
        ";;
    esac
done

