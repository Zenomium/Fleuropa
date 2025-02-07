DROP VIEW IF EXISTS statistiques CASCADE;
DROP TABLE IF EXISTS contient CASCADE;
DROP TABLE IF EXISTS possede CASCADE;
DROP TABLE IF EXISTS commande CASCADE;
DROP TABLE IF EXISTS bouquet CASCADE;

DROP TABLE IF EXISTS client CASCADE;
DROP TABLE IF EXISTS magasin CASCADE;
DROP TABLE IF EXISTS mode_livraison CASCADE;
DROP TABLE IF EXISTS fleur CASCADE;



------------------------------------------------------------------------------------------------------------
---------------------------------------- La création des tables --------------------------------------------
------------------------------------------------------------------------------------------------------------

CREATE TABLE client (
	num_cli serial PRIMARY KEY,
	nom_cli VARCHAR(50) NOT NULL,	
	prenom_cli VARCHAR(50) NOT NULL,
	tel_cli CHAR(10) NOT NULL UNIQUE,			-- CHAR parce que "0601020304" - 10 caractères, les numéros français
	email_cli VARCHAR(100) NOT NULL UNIQUE, 	-- un email = un client
	mdp VARCHAR(60) DEFAULT NULL,  				-- Hachage. D'après le cours on ne stocke JAMAIS de mots de passe en clair!
	abonne BOOLEAN DEFAULT '0'
);


CREATE TABLE magasin (
	ref_mag serial PRIMARY KEY,
	nom_mag VARCHAR(50) NOT NULL,
	adresse_mag VARCHAR(50) NOT NULL,
	ville_mag VARCHAR(50) NOT NULL UNIQUE
);


CREATE TABLE mode_livraison (
	id_livr serial PRIMARY KEY,
	mode VARCHAR(11) DEFAULT 'Chronopost',
	prenom_coursier VARCHAR(50) DEFAULT NULL,
	nom_coursier VARCHAR(50) DEFAULT NULL
);


CREATE TABLE fleur (
	ref_fleur serial PRIMARY KEY,
	nom_fleur VARCHAR(20) NOT NULL UNIQUE,
	description_fleur VARCHAR(255),
	prix NUMERIC(6, 2) NOT NULL				-- euro, centimes 0000,00 autrement dit 9999.99€ maximum 
);




CREATE TABLE commande (
	ref_com serial PRIMARY KEY,
	date_com DATE DEFAULT CURRENT_DATE,		-- la date actuelle
	etat_com VARCHAR(50) NOT NULL,
	nom_dest VARCHAR(50) NOT NULL,
	prenom_dest VARCHAR(50) NOT NULL,
	tel_dest CHAR(10),
	adresse_dest VARCHAR(50) NOT NULL,
	ville_dest VARCHAR(50) NOT NULL,
	message_dest TEXT,
	date_livraison DATE,
	url_photo_com VARCHAR(255),
	num_cli integer,			-- num_cli fait référence à client(num_cli)
	ref_mag integer,  			-- ref_mag fait référebce à magasin(ref_mag)
	id_livr integer				-- id_livr fait référebce à mode_livraison(id_livr)
);


ALTER TABLE commande
    ADD CONSTRAINT commande_num_cli_fkey FOREIGN KEY (num_cli) REFERENCES client(num_cli);

ALTER TABLE commande
    ADD CONSTRAINT commande_ref_mag_fkey FOREIGN KEY (ref_mag) REFERENCES magasin(ref_mag);

ALTER TABLE commande
    ADD CONSTRAINT commande_id_livr_fkey FOREIGN KEY (id_livr) REFERENCES mode_livraison (id_livr);





CREATE TABLE bouquet (
	ref_bouq serial PRIMARY KEY,	
	quantite integer DEFAULT 1,  	-- la quantite des fleurs dans le bouquet
	ref_fleur integer  				-- un bouquet est composé par un type de fleur
);

ALTER TABLE bouquet
    ADD CONSTRAINT bouquet_ref_fleur_fkey FOREIGN KEY (ref_fleur) REFERENCES fleur(ref_fleur);





CREATE TABLE contient (
	ref_com integer,
	ref_bouq integer,
	PRIMARY KEY (ref_com, ref_bouq)
);

ALTER TABLE contient
    ADD CONSTRAINT contient_ref_com_fkey FOREIGN KEY (ref_com) REFERENCES commande(ref_com);

ALTER TABLE contient
    ADD CONSTRAINT contient_ref_bouq_fkey FOREIGN KEY (ref_bouq) REFERENCES bouquet(ref_bouq);




CREATE TABLE possede (
	ref_mag integer,
	id_livr integer,
	CONSTRAINT cle_prim_possede PRIMARY KEY (ref_mag, id_livr)
);

ALTER TABLE possede
    ADD CONSTRAINT possede_ref_mag_fkey FOREIGN KEY (ref_mag) REFERENCES magasin(ref_mag);

ALTER TABLE possede
    ADD CONSTRAINT possede_id_livr_fkey FOREIGN KEY (id_livr) REFERENCES mode_livraison(id_livr);




------------------------------------------------------------------------------------------------------------
--------------------------------------- Les insert dans la base --------------------------------------------
------------------------------------------------------------------------------------------------------------


-- 4 clients
-- Pour les demandes de l’entreprise Fleuropa

INSERT INTO client (nom_cli, prenom_cli, tel_cli, email_cli, mdp, abonne)
VALUES ('Moulin', 'Jean', '0601020304', 'jean.moulin@gmail.com', 'DNANnjd46%', '1');

INSERT INTO client (nom_cli, prenom_cli, tel_cli, email_cli, mdp, abonne)
VALUES ('Yeda', 'Hugo', '0601020804', 'hugo.yeda@gmail.com', NULL , '0');

INSERT INTO client (nom_cli, prenom_cli, tel_cli, email_cli, mdp, abonne)
VALUES ('Potter', 'Harry', '0777889900', 'harry.potter@pix.fr', 'NEw_Pass!word%', '1');

INSERT INTO client (nom_cli, prenom_cli, tel_cli, email_cli, mdp, abonne)
VALUES ('Carac', 'Terra', '0767258654', 'terra.carac@mail.fr', '$Paris_Terra0', '1');

INSERT INTO client (nom_cli, prenom_cli, tel_cli, email_cli, mdp, abonne)
VALUES ('Nom', 'Prenom', '0612345678', 'test@test.fr', 'password', '1');



-- 30 magasins et 'Siege vert' c'est la société Fleuropa, dont le siège est à Lyon
INSERT INTO magasin (nom_mag, adresse_mag, ville_mag) VALUES 
('Siege vert', '1 Rue de la République', 'Lyon'), ('Main verte', '34 Boulevard Haussmann', 'Marseille'), 
('Bras vert', '61 Rue Faidherbe', 'Paris'),('Jambe verte', '36 Avenue des Minimes', 'Toulouse'), 
('Doigt vert', '3 Rue de la Victoire', 'Nice'), ('Tete vert', '13 Rue de la Paix', 'Nantes'),
('Corps vert', '42 Avenue des Tanneurs', 'Strasbourg'), ('Esprit vert', '16 Rue du Palais', 'Montpellier'), 
('Mind vert', '18 Avenue des Gobelins', 'Lille'),('Chez le monde vert', '99 Boulevard des Belges', 'Bordeaux'), 
('Le vert', '13 Avenue Montaigne', 'Reims'), ('My vert', '4 Rue du Faubourg Saint-Antoine', 'Saint-Étienne'), 
('Autre vert', '8 Place Stanislas', 'Nancy'), ('Nouveau vert', '23 Rue du Cherche-Midi', 'Rennes'), 
('Grand vert', '55 Rue de la Pompe', 'Clermont-Ferrand'), ('Petit vert', '29 Quai des Grands Augustins', 'Tours'), 
('Beau vert', '7 Rue de la Liberté', 'Limoges'), ('Vieux vert', '19 Rue Sainte-Catherine', 'Angers'),
('Simple vert', '25 Rue du Faubourg Saint-Honoré', 'Toulon'), ('Grand vert', '48 Rue des Petits Champs', 'Nîmes'), 
('Belle vert', '12 Place de la Bourse', 'Saint-Denis'), ('Bons vert', '14 Avenue de l Opéra', 'Besançon'), 
('Cote vert', '6 Rue de Rivoli', 'Orléans'), ('Double vert', '31 Rue Saint-Jacques', 'Mulhouse'),
('Vert Paradis', '21 Rue du Cherche-Midi', 'Aix-en-Provence'), ('Fleur du Vert', '28 Avenue des Gobelins', 'Béziers'),
('Oasis vert', '45 Rue des Petits Champs', 'Le Mans'), ('Secret vert', '9 Quai des Grands Augustins', 'Brest'), 
('Petit Jardin vert', '17 Rue Sainte-Catherine', 'Caen'), ('Escale vert', '26 Rue du Faubourg Saint-Honoré', 'Metz');




-- 8 fleurs
INSERT INTO fleur (nom_fleur, description_fleur, prix) VALUES 
('roses', 'La rose des jardins se caractérise avant tout par la multiplication de ses pétales imbriqués, qui lui donne sa forme caractéristique.', 0.99), 
('tulips', 'La tulipe rouge est un symbole de passion et d''amour intense.', 0.80), 
('peonies', 'La pivoine est le symbole de la beauté féminine et de l''amour.', 1.20), 
('sunflowers', 'Le tournesol symbolise le soleil, l''amour et la fidélité.', 1.30),
('gypsophiles', 'La gypsophile forme un buisson rond très ramifié, qui atteint facilement un mètre en tout sens.', 1.00), 
('lisianthus', 'Le lisianthus a l''air doux et fragile, sa symbolique est forte, véhiculant des messages de respect, de gratitude et de charisme.', 1.50), 
('lilacs', 'Le lilas a une signification amoureuse ; blanc, c''est l''innocence, mauve, c''est l''amour naissant.', 2.00), 
('hydrangeas', 'Dans le langage des fleurs, l''hortensia est notamment associé à la gratitude.', 0.65);



-- ref_bouq est serial
INSERT INTO bouquet (quantite, ref_fleur) VALUES 
(1, 1), (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8);



-- 31 id_livr totale pour chaque magasin 1 coursier si magasin n'existe pas dans le ville de destinataire, alors c'est Chronopost
INSERT INTO mode_livraison (mode, prenom_coursier, nom_coursier) VALUES
('Chronopost', NULL, NULL), ('Coursier', 'Marc', 'Hausemann'), ('Coursier', 'Alex', 'Terrieur'), 
('Coursier', 'Emily', 'Richards'), ('Coursier', 'Lucas', 'Martin'),('Coursier', 'Sophia', 'Beaumont'), 
('Coursier', 'Nathan', 'Lefebvre'), ('Coursier', 'Isabella', 'Lemieux'),('Coursier', 'Oliver', 'Rousseau'), 
('Coursier', 'Chloe', 'Laporte'), ('Coursier', 'Gabriel', 'Fournier'),('Coursier', 'Liam', 'Roy'), 
('Coursier', 'Eva', 'Lefevre'), ('Coursier', 'Hugo', 'Dubois'), ('Coursier', 'Léa', 'Blanc'),
('Coursier', 'Thomas', 'Moreau'), ('Coursier', 'Inès', 'Girard'), ('Coursier', 'Louis', 'Lemoine'),
('Coursier', 'Camille', 'Lefort'), ('Coursier', 'Arthur', 'Roux'), ('Coursier', 'Emma', 'Mercier'),
('Coursier', 'Paul', 'Berger'), ('Coursier', 'Manon', 'Lefevre'), ('Coursier', 'Maxime', 'Gauthier'),
('Coursier', 'Juliette', 'Dupont'), ('Coursier', 'Antoine', 'Lambert'), ('Coursier', 'Mia', 'Leroux'),
('Coursier', 'Adam', 'Robert'), ('Coursier', 'Léna', 'Nicolas'), ('Coursier', 'Nolan', 'Leclerc'),
('Coursier', 'Yannis', 'Youtube');




-- 4 commandes pour les demandes de l’entreprise Fleuropa
INSERT INTO commande (date_com, etat_com, nom_dest, prenom_dest, tel_dest, adresse_dest, ville_dest, message_dest, date_livraison, num_cli, ref_mag, id_livr)
VALUES ('2023-01-01', 'préparation', 'Lavoisier', 'Antoine', '0745948160', '2 avenue des Champs-Elysées', 'Eauze', 'Merci pour tout', '2023-02-07', 1, 1, 1); 

INSERT INTO commande (etat_com, nom_dest, prenom_dest, tel_dest, adresse_dest, ville_dest, date_livraison, num_cli, ref_mag, id_livr)
VALUES ('livraison', 'Dupond', 'Max', '0645578301', '3 bis boulevard Voltaire', 'Poitiers', '2023-02-10', 2, 1, 2);

INSERT INTO commande (date_com, etat_com, nom_dest, prenom_dest, tel_dest, adresse_dest, ville_dest, message_dest, date_livraison, num_cli, ref_mag, id_livr)
VALUES ('2022-12-09', 'livré', 'MBappé', 'Kylian', '0755880496', '5 Rue de Vanves', 'Bondy', 'Joyeux anniveraire Kylian !', '2022-12-20', 3, 2, 3);

INSERT INTO commande (date_com, etat_com, nom_dest, prenom_dest, tel_dest, adresse_dest, ville_dest, message_dest, num_cli, ref_mag, id_livr)
VALUES ('2023-02-05', 'préparation', 'Lavoisier', 'Antoine', '0745948160', '25 rue des pies', 'Angers', 'Comment cetait ton déménagement ?', 4, 3, 1); 	
--Bouquet en cours de préparation dont on ne connaît pas la date de livraison.



-- client-A a commande-A bouquet-A
-- client-A ne peux pas avoir d'autre commande-A
-- mais client-A peut effectuer la commande-B etc...

INSERT INTO contient (ref_com, ref_bouq) VALUES (1, 3), (2, 2), (3, 1);



-- (1, 1) c'est Lyon et le siège
INSERT INTO possede (ref_mag, id_livr) VALUES (1, 1),
(1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 7), (7, 8), (8, 9), (9, 10), (10, 11), 
(11, 12), (12, 13), (13, 14), (14, 15), (15, 16), (16, 17), (17, 18), (18, 19), (19, 20), (20, 21), 
(21, 22), (22, 23), (23, 24), (24, 25), (25, 26), (26, 27), (27, 28), (28, 29), (29, 30), (30, 31);




------------------------------------------------------------------------------------------------------------
---------------------------------- les demandes de l’entreprise Fleuropa -----------------------------------
------------------------------------------------------------------------------------------------------------


CREATE VIEW statistiques AS (
	SELECT ville_dest AS ville,
			date_com,
			COUNT(ref_com) AS nombre_commandes,
			COUNT(ref_bouq) AS nb_bouquets_vendus
	FROM commande 
	NATURAL JOIN contient
	GROUP BY ville_dest, date_com);


-- le nombre de bouquets commandés dans chaque ville.
SELECT ville, 
	SUM(nb_bouquets_vendus) AS total_bouquets_vendus
	FROM statistiques
	GROUP BY ville;


-- le nombre de commandes par jour.
SELECT date_com,
	SUM(nombre_commandes) AS total_commandes
	FROM statistiques
	GROUP BY date_com;


-- Fait par MATHIEU J.
-- et MUNAITPASOV M.

-- Chargé de TP est YVONNET P.
