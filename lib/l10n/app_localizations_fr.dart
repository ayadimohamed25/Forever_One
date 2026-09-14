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
  String get system => 'système';

  @override
  String get language => 'Langue';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get days => 'j';
}
