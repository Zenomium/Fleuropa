# Coding UTF-8
# 21 Décembre 2023
# Fait par MATHIEU J.
# et MUNAITPASOV M.
# Chargé de TP YVONNET P.


# pylint main.py
# Your code has been rated at 8.32/10 (previous run: 8.32/10, +0.00)


from passlib.context import CryptContext
from flask import Flask, render_template, request, redirect, url_for, session
import db

app = Flask(__name__)
password_ctx = CryptContext(schemes=['bcrypt'])     # configuration de la bibliothèque
app.secret_key = b'5a9284639d2d983f121a291dc6b5e5272808ab2d033947d554bac6df178d1f69'


fleurs = ["Roses", "Tulips", "Peonies", "Sunflowers",\
         "Gypsophiles", "Lisianthus", "Lilacs", "Hydrangeas"]

types_fleurs = {"roses": "roses.jpg",
    "tulips": "tulips.jpg",
    "peonies": "peonies.jpg",
    "sunflowers": "sunflowers.jpg",
    "gypsophiles":  "gypsophile.jpg",
    "lisianthus": "lisianthus.jpg",
    "lilacs": "lilacs.jpg",
    "hydrangeas": "hydrangeas.jpeg",
    }



# l'acceuil
@app.route('/')
def acceuil():
    return render_template('index.html', types_fleurs = types_fleurs)



# chaque fleur
@app.route('/<string:fleur>')
def fleur_page(fleur):
    fleur_tuple = []
    descrip_fl = None
    prix_unit = None

    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM fleur WHERE nom_fleur = %s", (fleur,))
            flower = cur.fetchone()

    if flower is not None:
        descrip_fl = flower.description_fleur
        prix_unit = flower.prix

    for nom_fleur, fleur_jpg in types_fleurs.items():
        if nom_fleur == fleur:
            fleur_couple = [nom_fleur, fleur_jpg]
            break
    else:
        return render_template('flower_not_found.html')

    return render_template('flower.html', fleur_couple = fleur_couple, \
                            descrip_fl = descrip_fl, prixU = prix_unit)



# acheter des bouquets
@app.route('/buy', methods=['GET'])
def buy():

    if 'logged_in' in session and session['logged_in']:
        return render_template('buy_in.html', fleurs = fleurs)    # connecté(e)
    
    return render_template('buy.html', fleurs = fleurs)           # déconnecté



# le travail avec la BDD, l'insertion et les mis à jour
@app.route('/purchase', methods=['POST'])
def purchase():
    if request.method == 'POST':
        type_fleur = request.form['flower_type']
        quantite = int(request.form['quantity'])
        prix_total = 0

        nom_dest = request.form['recipient_last_name']
        prenom_dest  = request.form['recipient_first_name']
        telephone_dest  = request.form['recipient_telephone']
        address_dest  = request.form['recipient_address']
        ville_dest  = request.form['recipient_city']
        message_dest = request.form['message']
        etat_com = 'En cours de préparation'  # livré, livraison au fur à mesure
        delivery_mode = 1
        ref_bouquet = 0

        client_tmp = None
        num_cli_tmp = None
        duplicata = None
        err_duplicata = 0

        # utilisateur n'est pas connecté
        if 'logged_in' not in session or not session['logged_in']:
            last_name = request.form['last_name']
            first_name = request.form['first_name']
            telephone = request.form['telephone']
            email = request.form['email']
            abonne = '0'        # n'a pas de mot de pass donc n'est pas abonné

            with db.connect() as conn:
                with conn.cursor() as cur:
                    cur.execute("SELECT email_cli, tel_cli \
                                FROM client WHERE email_cli = %s OR tel_cli = %s", \
                                (email, telephone))
                    duplicata = cur.fetchone()

            # Il existe déjà dans la base de donnés email de client 
            if duplicata:
                err_duplicata = 1
                return render_template('buy.html',\
                    fleurs = fleurs, error_duplicata = err_duplicata,\
                    email = email, tel = telephone)           # déconnecté



            # Enregister le client
            with db.connect() as conn:
                with conn.cursor() as cur:
                    cur.execute("INSERT INTO \
                                client(nom_cli, prenom_cli, tel_cli, email_cli, abonne) \
                                VALUES (%s, %s, %s, %s, %s) RETURNING *", \
                                (last_name, first_name, telephone, email, abonne))
                    client_tmp = cur.fetchone()

            if client_tmp:
                num_cli_tmp = client_tmp.num_cli
        
        # utilisateur est connecté
        else:
            num_cli_tmp = session['num_cli']

        # l'insertion du bouquet
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute("INSERT INTO bouquet(quantite, ref_fleur)\
                    VALUES (%s, (SELECT ref_fleur FROM fleur WHERE nom_fleur = %s)) \
                    RETURNING *", (quantite, type_fleur))
                ref_bouquet = cur.fetchone()

        if ref_bouquet:
            session['ref_bouq'] = ref_bouquet.ref_bouq


        # le prix de commande
        with db.connect() as conn:
           with conn.cursor() as cur:
               cur.execute("SELECT (prix * quantite) AS prix_bouq \
                            FROM bouquet NATURAL JOIN fleur WHERE \
                            ref_bouq = %s", (session['ref_bouq'], ))
               prix_tmp = cur.fetchone()
        if prix_tmp:
            prix_total = prix_tmp.prix_bouq
                

        # récuperation de référence de magasin et de id de livraison
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT DISTINCT * FROM magasin \
                NATURAL JOIN possede NATURAL JOIN mode_livraison \
                WHERE ville_mag = %s", (ville_dest, ))
                ville_mag_livrason = cur.fetchone()


        if ville_mag_livrason:
            delivery_mode = ville_mag_livrason.id_livr 
            with db.connect() as conn:
                with conn.cursor() as cur:
                    cur.execute("SELECT ref_mag FROM magasin WHERE \
                                 ville_mag = %s", (ville_mag_livrason.ville_mag,))
                    ref_magasin = cur.fetchone()
        else:
            ref_magasin = 1  # à Lyon car on va envoyer par Chronopost

        # l'insertion du commande dans la BDD
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute("INSERT INTO commande \
                            (etat_com, nom_dest, prenom_dest, tel_dest, adresse_dest, \
                            ville_dest, message_dest, num_cli, ref_mag, id_livr) VALUES \
                            (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", \
                            (etat_com, nom_dest, prenom_dest, telephone_dest, address_dest, \
                            ville_dest, message_dest, num_cli_tmp, ref_magasin, delivery_mode))


        # la récuperation de ref_com nécessaire
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT * FROM commande WHERE \
                                num_cli = %s AND ref_mag = %s AND id_livr = %s", \
                                (num_cli_tmp, ref_magasin, delivery_mode))
                commande_tmp = cur.fetchone()
                
                if commande_tmp:
                    session['ref_com'] = commande_tmp.ref_com


        # mis à jour du table contient
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute("INSERT INTO contient (ref_com, ref_bouq) \
                     VALUES (%s, %s)", (session['ref_com'], session['ref_bouq']))

        return render_template('validation.html',\
                quantite = quantite, type_fleur = type_fleur, prix_total = prix_total)

    return render_template('index.html', types_fleurs = types_fleurs)  # si utilisateur utilise methode GET



# les coordonées bancaires
@app.route('/validation', methods=['POST'])
def validation():
    if request.method == 'POST':
        numero_cb = request.form['numero_cb']
        date_cb = request.form['date_cb']
        crypto = request.form['crypto']
        ref_com_print = session['ref_com']
        
        # on les traite pas
        print(f"Votre numero de card bancaire: {numero_cb}, \
la date sur CB: {date_cb}, et votre crypto {crypto}")
        
        return render_template('thank_you.html', ref_com_print = ref_com_print )

    return render_template('index.html', types_fleurs = types_fleurs)   # si utilisateur utilise methode GET



# la page de tracking
@app.route('/tracking')
def tracking():
    return render_template('tracking.html')



# l'affichage du résultat de tracking
@app.route('/track', methods=['POST'])
def track():
    if request.method == 'POST':
        ref_com = request.form.get('ref_com')
        date_com = None
        etat_com = None
        ville_dest = None
        mode_livr = None

        est_coursier = False
        nom_coursier, prenom_coursier = None, None
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT * FROM commande NATURAL JOIN \
                            mode_livraison WHERE ref_com = %s", (ref_com,))
                commande = cur.fetchone()

                if commande:
                    date_com = commande.date_com
                    etat_com = commande.etat_com
                    ville_dest = commande.ville_dest
                    mode_livr = commande.mode

        if date_com is None and etat_com is None and ville_dest is None:
            return render_template("tracking_error.html", ref_com = ref_com)

        # Afficher nom et prenom du coursier si mode de livraison est 'Coursier'
        if mode_livr == 'Coursier':
            with db.connect() as conn:
                with conn.cursor() as cur:
                    cur.execute("SELECT * FROM commande NATURAL JOIN \
                                mode_livraison WHERE ref_com = %s", (ref_com,))
                    coursier = cur.fetchone()
            if coursier:
                nom_coursier = coursier.nom_coursier
                prenom_coursier = coursier.prenom_coursier
            est_coursier = True

        return render_template("tracking_result.html",\
                ref_com = ref_com, ville_dest = ville_dest, \
                date_com = date_com, etat_com = etat_com, livraison = mode_livr, \
                est_coursier = est_coursier, nom_coursier = nom_coursier, \
                prenom_coursier = prenom_coursier)

    return render_template('index.html', types_fleurs = types_fleurs)



@app.route('/connection', methods=['GET', 'POST'])
def connection():
    if request.method == 'POST':

        email_cli = request.form.get('email_cli')
        password_conn = request.form.get('password')
        hash_mot_de_pass = None

        # vérification de hashage de notre mdp
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT mdp FROM client WHERE email_cli = %s", (email_cli, ))
                hash_vrai_mdp = cur.fetchone()
        
        if hash_vrai_mdp:
            hash_mot_de_pass = hash_vrai_mdp[0]

        # Client n'est pas entré
        if not(password_ctx.verify(password_conn, hash_mot_de_pass)):
            return render_template('connection.html')


        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT * FROM client WHERE email_cli = %s", (email_cli,))
                client = cur.fetchone()

                if client:

                    session['num_cli'] = client.num_cli
                    session['logged_in'] = True
                    return redirect(url_for('login_success'))
                
                else:
                    return render_template('connection.html')

    return render_template('connection.html')



# Nous sommes déconnecté à partir de maintenant
@app.route('/deconnection')
def deconnection():
    session.clear()
    return render_template('deconnection.html')



# Nous sommes connecté à partir de maintenant
@app.route('/login_success')
def login_success():
    if 'logged_in' in session and session['logged_in']:
        return render_template('login_success.html')
    else:
        return redirect(url_for('connection'))



@app.route('/registration', methods=['GET', 'POST'])
def registration():
    if request.method == 'POST':

        last_name = request.form.get('lastname')
        first_name = request.form.get('firstname')
        telephone = request.form.get('telephone')
        email = request.form.get('email')
        password = request.form.get('password')
        abonne = '1'

        hash_pw = password_ctx.hash(str(password))

        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute("INSERT INTO client\
                            (nom_cli, prenom_cli, tel_cli, email_cli, mdp, abonne) \
                            VALUES (%s, %s, %s, %s, %s, %s) RETURNING *", \
                            (last_name, first_name, telephone, email, hash_pw, abonne))
                new_client = cur.fetchone()

                session['num_cli'] = new_client.num_cli
                session['logged_in'] = True

        return redirect(url_for('login_success'))

    return render_template('registration.html')



if __name__ == '__main__':
    app.run()
