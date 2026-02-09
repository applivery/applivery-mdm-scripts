#!/bin/sh 

# ---
# Title: Create or Update Hidden Admin Account
# Description: Creates a hidden administrator account or updates its password and visibility if it already exists.
# Author: Applivery
# Version: 1.0.0
# ---

export PATH=/usr/bin:/bin:/usr/sbin:/sbin 

# ======== USER DETAILS ========
USERNAME="admin"  
FULLNAME="admin"  
PASSWORD="PASSWORD"
HIDDEN="yes"  # Set to "yes" to hide the user from the login window

# ======== FUNCTIONS ========

# Function to check if user exists
check_user_exists() {
    dscl . -list /Users | grep -q "^$USERNAME$"
    return $?
}

# Function to check if user is hidden
is_user_hidden() {
    dscl . -read /Users/$USERNAME IsHidden 2>/dev/null | grep -q "1"
    return $?
}

# Function to hide user
hide_user() {
    sudo defaults write /Library/Preferences/com.apple.loginwindow HiddenUsersList -array-add $USERNAME
    sudo chown root:wheel /Library/Preferences/com.apple.loginwindow.plist
}

# Function to unhide user
unhide_user() {
    sudo defaults delete /Library/Preferences/com.apple.loginwindow HiddenUsersList
}

# Function to update password
update_password() {
    sudo dscl . -passwd /Users/$USERNAME "$PASSWORD"
}

# ======== MAIN LOGIC ========

# Check if user exists
if check_user_exists; then
    echo "Usuario $USERNAME ya existe."
    
    # Update password automatically
    update_password
    echo "Contraseña actualizada para $USERNAME"
    
    # Check and update hidden status if needed
    current_hidden=$(is_user_hidden && echo "yes" || echo "no")
    if [ "$current_hidden" != "$HIDDEN" ]; then
        if [ "$HIDDEN" = "yes" ]; then
            hide_user
            echo "Usuario $USERNAME ha sido ocultado"
        else
            unhide_user
            echo "Usuario $USERNAME ha sido des-ocultado"
        fi
    fi
else
    # Create new user
    if [ "$HIDDEN" = "yes" ]; then
        HIDDEN_FLAG="-hidden"
    else
        HIDDEN_FLAG=""
    fi
    
    # Create the user with or without the hidden option
    sysadminctl -addUser "$USERNAME" -fullName "$FULLNAME" -password "$PASSWORD" -admin $HIDDEN_FLAG
    echo "Usuario $USERNAME creado exitosamente"
fi