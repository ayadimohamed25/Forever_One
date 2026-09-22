// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Forever One';

  @override
  String get appTagline => 'Le système d\'exploitation de votre entreprise';

  @override
  String get login => 'Connexion';

  @override
  String get loginSubtitle => 'Accédez à votre espace de gestion';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get signIn => 'Se connecter';

  @override
  String get logout => 'Déconnexion';

  @override
  String get copyright => 'ForeverSoftware © 2026';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String welcome(String email) {
    return 'Bienvenue, $email';
  }

  @override
  String get revenue => 'Chiffre d\'affaires';

  @override
  String get receivables => 'Créances';

  @override
  String get payables => 'Dettes';

  @override
  String get lowStockAlerts => 'Alertes stock';

  @override
  String get management => 'Gestion';

  @override
  String get aiCopilot => 'Copilote IA';

  @override
  String get insights => 'Analyses';

  @override
  String get generatePdfReport => 'Générer le rapport PDF';

  @override
  String get products => 'Produits';

  @override
  String get warehouses => 'Dépôts';

  @override
  String get movements => 'Mouvements';

  @override
  String get customers => 'Clients';

  @override
  String get suppliers => 'Fournisseurs';

  @override
  String get sales => 'Ventes';

  @override
  String get purchases => 'Achats';

  @override
  String get scanner => 'Scanner';

  @override
  String get audit => 'Audit';

  @override
  String get name => 'Nom';

  @override
  String get phone => 'Téléphone';

  @override
  String get price => 'Prix';

  @override
  String get cost => 'Coût';

  @override
  String get minThreshold => 'Seuil min';

  @override
  String get unit => 'Unité';

  @override
  String get quantity => 'Quantité';

  @override
  String get qty => 'Qté';

  @override
  String get note => 'Note';

  @override
  String get noteOptional => 'Note (optionnel)';

  @override
  String get creditLimit => 'Plafond de crédit';

  @override
  String get leadTimeDays => 'Délai de livraison (jours)';

  @override
  String get location => 'Emplacement';

  @override
  String get date => 'Date';

  @override
  String get amount => 'Montant';

  @override
  String get total => 'Total';

  @override
  String get status => 'Statut';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get refresh => 'Actualiser';

  @override
  String get delete => 'Supprimer';

  @override
  String get newProduct => 'Nouveau produit';

  @override
  String get newCustomer => 'Nouveau client';

  @override
  String get newSupplier => 'Nouveau fournisseur';

  @override
  String get newSale => 'Nouvelle vente';

  @override
  String get newPurchase => 'Nouvel achat';

  @override
  String get product => 'Produit';

  @override
  String get customer => 'Client';

  @override
  String get supplier => 'Fournisseur';

  @override
  String get warehouse => 'Dépôt';

  @override
  String get threshold => 'Seuil';

  @override
  String get margin => 'marge';

  @override
  String get creditLimitShort => 'Plafond';

  @override
  String get noProducts => 'Aucun produit';

  @override
  String get noCustomers => 'Aucun client';

  @override
  String get noSuppliers => 'Aucun fournisseur';

  @override
  String get noSales => 'Aucune vente';

  @override
  String get noPurchases => 'Aucun achat';

  @override
  String get noWarehouses => 'Aucun dépôt';

  @override
  String get tapPlusToAdd => 'Appuyez sur + pour en ajouter un';

  @override
  String get tapPlusToCreate => 'Appuyez sur + pour en créer une';

  @override
  String get tapPlusToRecord => 'Appuyez sur + pour en enregistrer un';

  @override
  String get addProductLine => 'Ajouter un produit';

  @override
  String get noLines => 'Aucune ligne';

  @override
  String linesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lignes',
      one: '1 ligne',
    );
    return '$_temp0';
  }

  @override
  String get addAtLeastOneProduct => 'Ajoutez au moins un produit';

  @override
  String get unitCost => 'Coût unitaire';

  @override
  String get confirmSale => 'Confirmer la vente';

  @override
  String get confirmPurchase => 'Confirmer l\'achat';

  @override
  String saleCreated(String total) {
    return 'Vente créée · Total $total DT';
  }

  @override
  String purchaseRecorded(String total) {
    return 'Achat enregistré · Total $total DT';
  }

  @override
  String get confirmed => 'Confirmée';

  @override
  String get cancelled => 'Annulée';

  @override
  String get draft => 'Brouillon';

  @override
  String get received => 'Reçu';

  @override
  String get payment => 'Paiement';

  @override
  String get movementType => 'Type de mouvement';

  @override
  String get stockIn => 'Entrée';

  @override
  String get stockOut => 'Sortie';

  @override
  String get transfer => 'Transfert';

  @override
  String get correction => 'Correction';

  @override
  String get recordMovement => 'Enregistrer le mouvement';

  @override
  String get stockMovement => 'Mouvement de stock';

  @override
  String movementRecorded(int stock) {
    return 'Mouvement enregistré · Stock actuel : $stock';
  }

  @override
  String currentStockAfter(int stock) {
    return 'Stock actuel après mouvement : $stock';
  }

  @override
  String get paidInFull => 'Entièrement payé';

  @override
  String get balanceDue => 'Solde à régler';

  @override
  String get alreadyPaid => 'Déjà payé';

  @override
  String get remainingDue => 'Reste dû';

  @override
  String percentSettled(String percent) {
    return '$percent % réglé';
  }

  @override
  String get recordPayment => 'Enregistrer un paiement';

  @override
  String get payFullAmount => 'Régler la totalité';

  @override
  String get paymentMethod => 'Mode de paiement';

  @override
  String get cash => 'Espèces';

  @override
  String get bankTransfer => 'Virement';

  @override
  String get check => 'Chèque';

  @override
  String get recordThePayment => 'Enregistrer le paiement';

  @override
  String get scanDocument => 'Scanner un document';

  @override
  String get photographInvoice => 'Photographiez une facture';

  @override
  String get amountsExtractedAutomatically =>
      'Les montants seront extraits automatiquement';

  @override
  String get camera => 'Caméra';

  @override
  String get gallery => 'Galerie';

  @override
  String get analyzingDocument => 'Analyse du document en cours...';

  @override
  String get extractionReliable => 'Extraction fiable';

  @override
  String get verificationAdvised => 'Vérification conseillée';

  @override
  String get verificationRequired => 'Vérification nécessaire';

  @override
  String extractionConfidence(int confidence) {
    return 'Confiance de l\'extraction : $confidence %';
  }

  @override
  String get checkAndCorrect => 'Vérifiez et corrigez si nécessaire';

  @override
  String get validateAndSave => 'Valider et enregistrer';

  @override
  String get rawExtractedText => 'Texte brut extrait';

  @override
  String get noTextDetected => '(aucun texte détecté)';

  @override
  String get documentValidated => 'Document validé et enregistré';

  @override
  String get aiAssistant => 'Assistant métier';

  @override
  String get askYourBusiness => 'Interrogez votre entreprise';

  @override
  String get askQuestionSubtitle =>
      'Posez une question sur vos ventes, votre stock ou vos clients';

  @override
  String get askYourQuestion => 'Posez votre question...';

  @override
  String get analyzingData => 'Analyse de vos données...';

  @override
  String get suggestStockRupture => 'Quels produits risquent une rupture ?';

  @override
  String get suggestCustomerDebts => 'Quels clients me doivent de l\'argent ?';

  @override
  String get suggestActivitySummary => 'Fais-moi un résumé de mon activité';

  @override
  String get insightsAndForecasts => 'Analyses & Prévisions';

  @override
  String get stock => 'Stock';

  @override
  String get dormant => 'Dormants';

  @override
  String get followUps => 'Relances';

  @override
  String get noStockData => 'Aucune donnée de stock';

  @override
  String get addProductsForForecasts =>
      'Ajoutez des produits pour voir les prévisions';

  @override
  String daysOfCoverage(int days, String rate) {
    return '$days jours de couverture · $rate/jour';
  }

  @override
  String get noRecentSales => 'Pas de ventes récentes';

  @override
  String orderUnits(int units) {
    return 'Commander $units unités';
  }

  @override
  String get rupture => 'Rupture';

  @override
  String get soon => 'Bientôt';

  @override
  String get ok => 'OK';

  @override
  String get noDormantProducts => 'Aucun produit dormant';

  @override
  String get allProductsSelling => 'Tous vos produits se vendent régulièrement';

  @override
  String get neverSold => 'Jamais vendu';

  @override
  String lastSaleDaysAgo(int days) {
    return 'Dernière vente il y a $days jours';
  }

  @override
  String get noCustomersYet => 'Aucun client';

  @override
  String get addCustomersForScores =>
      'Ajoutez des clients pour voir les scores';

  @override
  String get auditLog => 'Journal d\'audit';

  @override
  String get all => 'Tout';

  @override
  String get payments => 'Paiements';

  @override
  String get documents => 'Documents';

  @override
  String get logins => 'Connexions';

  @override
  String get reports => 'Rapports';

  @override
  String get ai => 'IA';

  @override
  String get connection => 'Connexion';

  @override
  String get saleCreatedAction => 'Vente créée';

  @override
  String get purchaseRecordedAction => 'Achat enregistré';

  @override
  String get paymentRecordedAction => 'Paiement enregistré';

  @override
  String get stockMovementAction => 'Mouvement de stock';

  @override
  String get documentValidatedAction => 'Document validé';

  @override
  String get aiQueryAction => 'Question IA';

  @override
  String get reportGeneratedAction => 'Rapport généré';

  @override
  String get noActionsRecorded => 'Aucune action enregistrée';

  @override
  String get noActionsOfThisType => 'Aucune action de ce type';

  @override
  String get restrictedAccess => 'Accès restreint';

  @override
  String get system => 'Système';

  @override
  String get language => 'Langue';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get days => 'j';

  @override
  String get search => 'Rechercher';

  @override
  String get searchProducts => 'Rechercher un produit...';

  @override
  String get searchCustomers => 'Rechercher un client...';

  @override
  String get searchSuppliers => 'Rechercher un fournisseur...';

  @override
  String get edit => 'Modifier';

  @override
  String get editProduct => 'Modifier le produit';

  @override
  String get deleteProduct => 'Supprimer le produit';

  @override
  String deleteConfirmTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get deleteConfirmMessage => 'Cette action est irréversible.';

  @override
  String get productInUse =>
      'Ce produit ne peut pas être supprimé car il est utilisé dans des ventes, achats ou mouvements de stock.';

  @override
  String get productDeleted => 'Produit supprimé';

  @override
  String get productUpdated => 'Produit modifié';

  @override
  String get currentStock => 'Stock actuel';

  @override
  String get inStock => 'en stock';

  @override
  String get details => 'Détails';

  @override
  String get barcode => 'Code-barres';

  @override
  String get noResults => 'Aucun résultat';

  @override
  String get tryDifferentSearch => 'Essayez un autre terme de recherche';

  @override
  String get customerDetails => 'Fiche client';

  @override
  String get supplierDetails => 'Fiche fournisseur';

  @override
  String get editCustomer => 'Modifier le client';

  @override
  String get editSupplier => 'Modifier le fournisseur';

  @override
  String get customerInUse =>
      'Ce client ne peut pas être supprimé car il a un historique de ventes.';

  @override
  String get supplierInUse =>
      'Ce fournisseur ne peut pas être supprimé car il a un historique d\'achats.';

  @override
  String get customerDeleted => 'Client supprimé';

  @override
  String get customerUpdated => 'Client modifié';

  @override
  String get address => 'Adresse';

  @override
  String get totalPurchases => 'Total des achats';

  @override
  String get outstandingBalance => 'Solde dû';

  @override
  String get orders => 'Commandes';

  @override
  String get lastOrder => 'Dernière commande';

  @override
  String get never => 'Jamais';

  @override
  String daysAgo(int days) {
    return 'il y a $days jours';
  }

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get creditUsage => 'Utilisation du crédit';

  @override
  String get creditLimitExceeded => 'Plafond de crédit dépassé';

  @override
  String get creditLimitNearlyReached => 'Plafond de crédit bientôt atteint';

  @override
  String get purchaseHistory => 'Historique des achats';

  @override
  String get noPurchaseHistory => 'Aucun achat pour le moment';

  @override
  String get contact => 'Contact';

  @override
  String get callCustomer => 'Appeler';

  @override
  String get sendEmail => 'Email';

  @override
  String get paid => 'payé';

  @override
  String get unpaid => 'impayé';

  @override
  String get taxId => 'Matricule fiscale';

  @override
  String get contactPerson => 'Personne à contacter';

  @override
  String get paymentTerms => 'Conditions de paiement';

  @override
  String get paymentTermsCash => 'Comptant';

  @override
  String paymentTermsDays(int days) {
    return '$days jours';
  }

  @override
  String get bankAccount => 'Compte bancaire (RIB)';

  @override
  String get notes => 'Notes';

  @override
  String get customerType => 'Type de client';

  @override
  String get individual => 'Particulier';

  @override
  String get company => 'Entreprise';

  @override
  String get supplierDeleted => 'Fournisseur supprimé';

  @override
  String get supplierUpdated => 'Fournisseur modifié';

  @override
  String get amountOwed => 'Montant dû';

  @override
  String get leadTime => 'Délai de livraison';

  @override
  String get deliveryReliability => 'Fiabilité des livraisons';

  @override
  String get noDeliveryData => 'Pas encore de données de livraison';

  @override
  String onTimeDeliveries(int onTime, int total) {
    return '$onTime sur $total à l\'heure';
  }

  @override
  String get reference => 'Référence';

  @override
  String get commercialInfo => 'Informations commerciales';

  @override
  String get totalOrders => 'Total des commandes';

  @override
  String get menu => 'Menu';

  @override
  String get roleAdmin => 'Administrateur';

  @override
  String get roleFinance => 'Responsable finance';

  @override
  String get roleStock => 'Responsable stock';

  @override
  String get roleCommercial => 'Commercial';

  @override
  String get roleEmployee => 'Employé';

  @override
  String get roleAuditor => 'Auditeur';

  @override
  String get business => 'Activité';

  @override
  String get intelligence => 'Intelligence';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Paramètres';

  @override
  String get logoutConfirmTitle => 'Se déconnecter ?';

  @override
  String get logoutConfirmMessage => 'Vous devrez vous reconnecter.';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get thisMonth => 'Ce mois-ci';

  @override
  String get vsLastMonth => 'vs mois dernier';

  @override
  String get noComparison => 'Pas de comparaison';

  @override
  String get stockValue => 'Valeur du stock';

  @override
  String get salesThisMonth => 'Ventes ce mois-ci';

  @override
  String get revenueTrend => 'Chiffre d\'affaires (30 derniers jours)';

  @override
  String get topProducts => 'Meilleurs produits';

  @override
  String get noSalesYet => 'Aucune vente enregistrée';

  @override
  String get alerts => 'Alertes';

  @override
  String get noAlerts => 'Rien ne requiert votre attention';

  @override
  String get allGood => 'Tout va bien';

  @override
  String lowStockAlert(String name) {
    return '$name est en rupture de stock';
  }

  @override
  String lowStockWarning(String name, int qty) {
    return '$name : plus que $qty en stock';
  }

  @override
  String creditExceededAlert(String name) {
    return '$name dépasse son plafond de crédit';
  }

  @override
  String overduePaymentAlert(String name, int days) {
    return '$name : $days jours de retard';
  }

  @override
  String get recentActivity => 'Activité récente';

  @override
  String get noActivity => 'Aucune activité';

  @override
  String get sale => 'Vente';

  @override
  String get purchase => 'Achat';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String unitsSold(int qty) {
    return '$qty vendus';
  }

  @override
  String get sku => 'Référence (SKU)';

  @override
  String get description => 'Description';

  @override
  String get category => 'Catégorie';

  @override
  String get categories => 'Catégories';

  @override
  String get newCategory => 'Nouvelle catégorie';

  @override
  String get editCategory => 'Modifier la catégorie';

  @override
  String get categoryInUse =>
      'Cette catégorie ne peut pas être supprimée car des produits l\'utilisent.';

  @override
  String get categoryDeleted => 'Catégorie supprimée';

  @override
  String get noCategories => 'Aucune catégorie';

  @override
  String get noCategory => 'Sans catégorie';

  @override
  String productCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produits',
      one: '1 produit',
      zero: 'Aucun produit',
    );
    return '$_temp0';
  }

  @override
  String get color => 'Couleur';

  @override
  String get vatRate => 'Taux de TVA';

  @override
  String get maxThreshold => 'Seuil maximum';

  @override
  String get shelfLocation => 'Emplacement';

  @override
  String get defaultSupplier => 'Fournisseur par défaut';

  @override
  String get saleUnit => 'Unité de vente';

  @override
  String get purchaseUnit => 'Unité d\'achat';

  @override
  String get unitsPerPurchase => 'Unités par unité d\'achat';

  @override
  String get active => 'Actif';

  @override
  String get inactive => 'Inactif';

  @override
  String get productActive => 'Produit actif';

  @override
  String get generalInfo => 'Informations générales';

  @override
  String get pricingAndVat => 'Prix & TVA';

  @override
  String get stockSettings => 'Paramètres de stock';

  @override
  String get unitsAndPackaging => 'Unités & conditionnement';

  @override
  String get productDetails => 'Fiche produit';

  @override
  String get stockHistory => 'Historique du stock';

  @override
  String get noStockHistory => 'Aucun mouvement de stock';

  @override
  String get priceHt => 'Prix HT';

  @override
  String get priceTtc => 'Prix TTC';

  @override
  String get marginAmount => 'Marge';

  @override
  String get filterByCategory => 'Filtrer par catégorie';

  @override
  String get allCategories => 'Toutes les catégories';

  @override
  String get showInactive => 'Afficher les inactifs';

  @override
  String get subtotalHt => 'Sous-total HT';

  @override
  String get totalVat => 'TVA';

  @override
  String get totalTtc => 'Total TTC';

  @override
  String get dueDate => 'Échéance';

  @override
  String get expectedDate => 'Livraison prévue';

  @override
  String get receivedDate => 'Reçu le';

  @override
  String get markAsReceived => 'Marquer comme reçu';

  @override
  String get purchaseReceived => 'Achat réceptionné';

  @override
  String get alreadyReceived => 'Cet achat est déjà réceptionné';

  @override
  String get overdue => 'En retard';

  @override
  String dueIn(int days) {
    return 'Échéance dans $days jours';
  }

  @override
  String get dueToday => 'Échéance aujourd\'hui';

  @override
  String get pendingDelivery => 'En attente de livraison';

  @override
  String get lineVat => 'TVA';

  @override
  String get invoiceDetails => 'Détails de la facture';

  @override
  String get optional => 'optionnel';

  @override
  String get searchSales => 'Rechercher une vente...';

  @override
  String get searchPurchases => 'Rechercher un achat...';

  @override
  String get editSale => 'Modifier la vente';

  @override
  String get editPurchase => 'Modifier l\'achat';

  @override
  String get saleHasPayments =>
      'Cette vente ne peut pas être modifiée ou supprimée car des paiements y sont enregistrés.';

  @override
  String get purchaseHasPayments =>
      'Cet achat ne peut pas être modifié ou supprimé car des paiements y sont enregistrés.';

  @override
  String get saleDeleted => 'Vente supprimée';

  @override
  String get saleUpdated => 'Vente modifiée';

  @override
  String get purchaseDeleted => 'Achat supprimé';

  @override
  String get purchaseUpdated => 'Achat modifié';

  @override
  String get stockWillBeRestored => 'Le stock sera restauré.';

  @override
  String get searchWarehouses => 'Rechercher un dépôt...';

  @override
  String get newWarehouse => 'Nouveau dépôt';

  @override
  String get editWarehouse => 'Modifier le dépôt';

  @override
  String get warehouseInUse =>
      'Ce dépôt ne peut pas être supprimé car il contient des mouvements de stock.';

  @override
  String get warehouseDeleted => 'Dépôt supprimé';

  @override
  String get warehouseUpdated => 'Dépôt modifié';

  @override
  String get code => 'Code';

  @override
  String get manager => 'Responsable';

  @override
  String get totalUnits => 'Unités en stock';

  @override
  String get distinctProducts => 'Produits';

  @override
  String get warehouseActive => 'Dépôt actif';

  @override
  String get users => 'Utilisateurs';

  @override
  String get user => 'Utilisateur';

  @override
  String get newUser => 'Nouvel utilisateur';

  @override
  String get editUser => 'Modifier l\'utilisateur';

  @override
  String get searchUsers => 'Rechercher un utilisateur...';

  @override
  String get noUsers => 'Aucun utilisateur';

  @override
  String get fullName => 'Nom complet';

  @override
  String get role => 'Rôle';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get passwordChanged => 'Mot de passe modifié';

  @override
  String get passwordReset => 'Mot de passe réinitialisé';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get wrongPassword => 'Le mot de passe actuel est incorrect';

  @override
  String get emailTaken => 'Cet email est déjà utilisé';

  @override
  String get invalidEmail => 'Adresse email invalide';

  @override
  String get lastAdmin =>
      'Vous ne pouvez pas retirer le dernier administrateur';

  @override
  String get cannotDeleteSelf =>
      'Vous ne pouvez pas supprimer votre propre compte';

  @override
  String get userHasActivity =>
      'Cet utilisateur ne peut pas être supprimé car il a de l\'activité dans le système. Désactivez-le plutôt.';

  @override
  String get userCreated => 'Utilisateur créé';

  @override
  String get userUpdated => 'Utilisateur modifié';

  @override
  String get userDeleted => 'Utilisateur supprimé';

  @override
  String get userActive => 'Compte actif';

  @override
  String get neverLoggedIn => 'Jamais connecté';

  @override
  String get lastLogin => 'Dernière connexion';

  @override
  String get myProfile => 'Mon profil';

  @override
  String get accountSecurity => 'Sécurité du compte';

  @override
  String get accessRights => 'Droits d\'accès';

  @override
  String permissionsCount(int count) {
    return '$count permissions';
  }

  @override
  String get accountDisabled =>
      'Ce compte a été désactivé. Contactez votre administrateur.';

  @override
  String get forbidden => 'Vous n\'avez pas la permission de faire cela';

  @override
  String get signUp => 'Créer un compte';

  @override
  String get signUpSubtitle => 'Installez votre entreprise sur Forever One';

  @override
  String get noAccountYet => 'Pas encore de compte ?';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get backToLogin => 'Se connecter';

  @override
  String get companyName => 'Nom de l\'entreprise';

  @override
  String get yourName => 'Votre nom';

  @override
  String get city => 'Ville';

  @override
  String get mainWarehouse => 'Dépôt principal';

  @override
  String get createMyAccount => 'Créer mon compte';

  @override
  String get accountCreated => 'Bienvenue sur Forever One';

  @override
  String get registrationFailed =>
      'L\'inscription a échoué, veuillez réessayer';

  @override
  String get companyInfo => 'Votre entreprise';

  @override
  String get yourAccount => 'Votre compte';

  @override
  String get signUpDisclaimer =>
      'Vous serez l\'administrateur de cette entreprise';

  @override
  String get searchCategories => 'Rechercher une catégorie...';

  @override
  String get partiallyPaid => 'Partiellement payé';

  @override
  String get exclVatShort => 'HT';

  @override
  String reasonOwes(String amount) {
    return 'Doit $amount';
  }

  @override
  String reasonNoPurchase(int days) {
    return 'Aucun achat depuis $days jours';
  }

  @override
  String get reasonUpToDate => 'À jour';

  @override
  String get followUpScore => 'Score de relance';

  @override
  String dueOn(String date) {
    return 'Échéance le $date';
  }

  @override
  String expectedOn(String date) {
    return 'Prévu le $date';
  }

  @override
  String receivedOn(String date) {
    return 'Reçu le $date';
  }

  @override
  String unitsInStock(int count) {
    return '$count unités en stock';
  }

  @override
  String get reasonNeverPurchased => 'Aucun achat enregistré';

  @override
  String auditCreated(String entity) {
    return 'Création · $entity';
  }

  @override
  String auditUpdated(String entity) {
    return 'Modification · $entity';
  }

  @override
  String auditDeleted(String entity) {
    return 'Suppression · $entity';
  }
}
