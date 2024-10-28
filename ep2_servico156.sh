#!/bin/bash
##################################################################
# MAC0216 - Técnicas de Programação I (2024)
# EP2 - Programação em Bash
#
# Nome do(a) aluno(a) 1: Fernando Ramos Takara
# NUSP 1: 13782230
#
# Nome do(a) aluno(a) 2: Natan José Martins Domingos
# NUSP 2: 15481350
##################################################################

#Variáveis para navegar pelos diretórios
dir_atual=$(pwd)
dir_dados="/Dados"

function selecionar_arquivo {
    echo
    rm $dir_atual$dir_dados/.csv
    echo Escolha uma opção de arquivo:
    select arq_escolhido in $(ls $dir_atual$dir_dados | tr '\n' ' '); do
        #Salva todas as reclamações do arquivo escolhido no arquivo escondido suporte
        tail -n +2 $dir_atual$dir_dados/$arq_escolhido > $dir_atual$dir_dados/.csv
        break
    done
    #Limpa os filtros
    limpar_filtros_colunas
}

function adicionar_filtro_coluna {
    echo
    echo Escolha uma opção de coluna para o filtro:
    select coluna_escolhida in "${colunas[@]}"; do
        coluna_indice=$(head $dir_atual$dir_dados/$arq_escolhido | tr ';' '\n' | grep -n "^$coluna_escolhida$" | cut -d: -f1)
        break
    done
    echo
    
    echo Escolha uma opção de valor para "$coluna_escolhida":
    filtro_selecionar=()
    for i in $(cat $dir_atual$dir_dados/.csv | cut -d ';' -f$coluna_indice | grep -v '^$' | sort | uniq | tr ' \n' '@ '); do
        filtro_selecionar+=("$(echo $i | tr '@' ' ')")
    done
    select filtro_escolhido in "${filtro_selecionar[@]}"; do
        break
    done
    echo +++ Adicionado filtro: "$coluna_escolhida" = "$filtro_escolhido"
    echo +++ Arquivo atual: $arq_escolhido
    grep "$filtro_escolhido" $dir_atual$dir_dados/.csv > $dir_atual$dir_dados/temp.csv
    cat $dir_atual$dir_dados/temp.csv > $dir_atual$dir_dados/.csv
    rm $dir_atual$dir_dados/temp.csv
    filtros_salvos[numero_filtros]=$(echo $coluna_escolhida = $filtro_escolhido | tr ' ' '@')
    numero_filtros=$(echo "$numero_filtros + 1" | bc)
    echo +++ Filtros atuais:
    filtros_atuais
    echo -n +++ Número de reclamações: 
    echo $(cat $dir_atual$dir_dados/.csv | wc -l | cut -d ' ' -f1)
    echo +++++++++++++++++++++++++++++++++++++++
    echo
}

function limpar_filtros_colunas {
    filtros_salvos=()
    numero_filtros="0"
    tail -n +2 $dir_atual$dir_dados/$arq_escolhido > $dir_atual$dir_dados/.csv
    echo +++ Arquivo atual: $arq_escolhido
    echo +++ Número de reclamações: "$(cat $dir_atual$dir_dados/.csv | wc -l | cut -d ' ' -f1)"
    echo +++++++++++++++++++++++++++++++++++++++
    echo
}

function mostrar_duracao_media_reclamacao {
    #Utiliza do vetor filtros_salvos e o formata de maneira apropriada para que seja possível filtrar as linhas relevantes para a função
    filtros_salvos_sup=()
    for i in "${filtros_salvos[@]}"; do
        filtros_salvos_sup+=("$(echo $i | cut -d '=' -f2 | cut --complement -c 1 | tr '@' ' ')")
    done
    cat $dir_atual$dir_dados/$arq_escolhido > $dir_atual$dir_dados/temp.csv
    for filtro in "${filtros_salvos_sup[@]}"; do
        grep "$filtro" $dir_atual$dir_dados/temp.csv > $dir_atual$dir_dados/temp2.csv
        cat $dir_atual$dir_dados/temp2.csv > $dir_atual$dir_dados/temp.csv
    done
    #A data de abertura está na coluna 1, enquanto a data de parecer se situa na coluna 13 do arquivo original
    grep 'FINALIZADA' $dir_atual$dir_dados/temp.csv | cut -d ';' -f 1,13 | tr ';' ' ' | cut -d ' ' -f 1,3 > $dir_atual$dir_dados/temp2.csv
    total_dias=0
    casos=0
    while read abertura parecer; do
        dif_dias=$(( ("$(date -d $parecer +%s)"-"$(date -d $abertura +%s)")/86400 ))
        total_dias=$(( total_dias+dif_dias ))
        casos=$(( casos+1 ))
    done < "$dir_atual$dir_dados/temp2.csv"
    rm $dir_atual$dir_dados/temp.csv
    rm $dir_atual$dir_dados/temp2.csv
    let media=total_dias/casos
    echo +++ Duração média da reclamação: $media dias
    echo +++++++++++++++++++++++++++++++++++++++
    echo 
}

function mostrar_ranking_reclamacoes {
    echo
    echo Escolha uma opção de coluna para análise:
    select coluna_escolhida in "${colunas[@]}"; do
        echo +++ Tema com mais reclamações:
        #Transforma o tema em um indice e com ele pega os casos mais frequentes e especificos das reclamações da coluna selecionada
        coluna_indice=$(head $dir_atual$dir_dados/$arq_escolhido | tr ';' '\n' | grep -n "^$coluna_escolhida$" | cut -d: -f1)
        cat $dir_atual$dir_dados/.csv | cut -d ';' -f$coluna_indice | grep -v '^$' | sort | uniq -c | sort -n -r | head -n 5
        echo +++++++++++++++++++++++++++++++++++++++
        break
    done
    echo
}

function mostrar_reclamacoes {
    cat $dir_atual$dir_dados/.csv 
    echo +++ Arquivo atual: $arq_escolhido
    echo +++ Filtros atuais:
    filtros_atuais
    echo -n +++ Número de reclamações: 
    echo $(cat $dir_atual$dir_dados/.csv | wc -l | cut -d ' ' -f1)
    echo +++++++++++++++++++++++++++++++++++++++
    echo
}

function sair {
    #Apaga o arquivo suporte de reclamações e termina o script
    echo Fim do programa
    echo +++++++++++++++++++++++++++++++++++++++
    rm $dir_atual$dir_dados/.csv
    exit 0
}

function filtros_atuais {
#Mostra os filtros salvos
for i in $(seq $(echo ${#filtros_salvos[*]})); do
    if [ $i != ${#filtros_salvos[*]} ]; then
        i=$(echo "$i - 1" | bc)
        echo -n ${filtros_salvos[$i]} | tr '@' ' '
        echo -n " | "
    else
        i=$(echo "$i - 1" | bc)
        echo ${filtros_salvos[$i]} | tr '@' ' '
    fi 
done
}

echo "+++++++++++++++++++++++++++++++++++++++
Este programa mostra estatísticas do
Serviço 156 da Prefeitura de São Paulo
+++++++++++++++++++++++++++++++++++++++"


#Se o número de parâmetros for diferente de 0, então baixamos os n URL's com o wget no path_atual/Dados. 
#Além disso, modificamos a codificação do arquivo csv baixado de ISO-8859-1 para UTF+8 com o iconv, deletando o antigo.
if [ $# != 0 ]; then
    wc $1 &> /dev/null || { echo "ERRO: O arquivo "$1" não existe. "; exit 1; } #Caso não ache o programa, o script termina 
    wget -nv -i $1 -P "$dir_atual$dir_dados"
    for i in $(ls "$dir_atual$dir_dados" | head -n $(wc $1 -w 2> /dev/null | cut -d' ' -f1) 2> /dev/null); do 
        nome_arq=$(echo $i)
        iconv -f ISO-8859-1 -t UTF8 $dir_atual$dir_dados/$nome_arq -o $dir_atual$dir_dados/temp.csv #Converte o aquivo baixado para UTF8 e armazena no temp.csv
        #Apaga o arquivo original e o temp.csv vira o arquivo antigo, porém, convertido
        rm $dir_atual$dir_dados/$nome_arq
        mv $dir_atual$dir_dados/temp.csv $dir_atual$dir_dados/$nome_arq 
        if [ -e "$dir_atual$dir_dados/arquivocompleto.csv" ]; then
            #Se o arquivocompleto já existe, pula o cabeçalho da coluna
            tail -n +2 $dir_atual$dir_dados/$nome_arq >> $dir_atual$dir_dados/arquivocompleto.csv
        else
            #Caso contrário, cria o arquivocompleto com o cabeçalho
            cat $dir_atual$dir_dados/$nome_arq > "$dir_atual$dir_dados/arquivocompleto.csv"
        fi
    done
fi 

#Remove o suporte que contem as reclamações para evitar falso positivo quando checar o arquivo baixado
rm $dir_atual$dir_dados/.csv 2> /dev/null

#Checa se tem arquivos baixados
if [ ! "$(ls "$dir_atual$dir_dados" 2> /dev/null)" ]; then
   echo "ERRO: Não há dados baixados.
Para baixar os dados antes de gerar as estatísticas, use:
  ./ep2_servico156.sh <nome do arquivo com URLs de dados do Serviço 156>"
  exit 1
fi

#Por padrão, o arquivo selecionado é o arquivocompleto.csv, no começo não há nenhum filtro e o arquivo suporte .csv contém todas as reclamações do arquivocompleto.csv
arq_escolhido="arquivocompleto.csv"
numero_filtros="0"
touch $dir_atual$dir_dados/.csv
tail -n +2 $dir_atual$dir_dados/$arq_escolhido > $dir_atual$dir_dados/.csv
echo

#Define as colunas que o arquivo contém
for i in $(head -n +1 $dir_atual$dir_dados"/"$arq_escolhido | tr ' ;' '@ '); do
    colunas+=("$(echo $i | tr '@' ' ')")
done

#O usuário escolhe uma opção e chama a respectiva função
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
        3 ) echo +++ Filtros removidos
        limpar_filtros_colunas;;
        4 ) mostrar_duracao_media_reclamacao;;
        5 ) mostrar_ranking_reclamacoes;;
        6 ) mostrar_reclamacoes;;
        7 ) sair;;
        *) echo "Comando Invalido
+++++++++++++++++++++++++++++++++++++++
";;
    esac
done
