#!/usr/bin/env bash
function configure
{
    echo 'SASL_PASSWD DOES NOT EXIST. Creating one'
    read -s "Input the user name of your gmail: (DO NOT INCLUDE @GMAIL)" email_usr
    read -s "Input the password of your gmail: " email_pass
    echo "smtp.gmail.com:587 $email_usr@gmail.com:$email_pass" > /etc/postfix/sasl_passwd
    
    echo "Updating the look up table with your credentials..."
    
    echo 'MAIN.CF DOES NOT EXIST. Creating one'
    printf 'mydomain_fallback = localhost\n
    mail_owner = postfix\n
    setgid_group = postdrop\n
    relayhost=smtp.gmail.com:587\n
    smtp_sasl_auth_enable=yes\n
    smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd\n
    smtp_use_tls=yes\n
    smtp_tls_security_level=encrypt\n
    tls_random_source=dev:/dev/urandom\n' > /etc/postfix/main.cf
    exit 1
}
# checks for dependcies:
# 1) assumes postfix is already installed
[[ -f /etc/postfix/sasl_passwd && -f /etc/postfix/main.cf || "$1" == "-c" ]] || { export -f configure; su -c root 'configure'; }

[[ "$1" == "" ]] && { echo -e 'No files to check selected
Review how to use the script\n'; exit 1; }
[[ -f "$1c" ]] && { echo -e 'Solution .pyc file does not exist.
Please download the solution file\n'; exit 1; }

# 2) checks if the "magic number" of python matches with mine

# version # of source python compiler
PYC_VER_NUM='2.7.2'

# grab the magic # of the .pyc
PYC_MAG_NUM=$((hexdump -x "$1.pyc") | head -4)

PY_RUN='import imp; imp.get_magic().encode('hex')'

# assumes python is already installed so no checking

# if the # is same
if [[ $(python -v) != pyc_ver_num ]]; then
    echo -e "Warning: Python versions do not work, checking magic # instead\n"
    if [[ $(python -c PY_RUN) != PYC_MAG_NUM ]]; then
        echo -e "Magic numbers match and checking can proceed...\n"
    else
        echo -e "Magic numbers do not match. Creating log files and sending report to Khang\n"
        exit 1
    fi
fi

echo "grading your hw"
python "$1c" > "$1_solutions.txt"
python "$1" > "$1_Answers.txt"

diff "$1_Solutions.txt" "$1_Answers.txt"
echo "Mailing the results to khang..."
echo mailing content...
read -p "Insert any comments you'd like to tell me about your HW or attempt: " comments
uuencode $1 $1 | mail $comments -s "$1 Attempt" khangvu200391845@gmail.com