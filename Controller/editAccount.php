<?php
var_dump($_POST);
ob_start();
if (!empty($_POST)) {
    require "../Models/Account.php";
    session_start();
    $account = unserialize($_SESSION['Account']);
    $username = filter_var($_POST['username'], FILTER_SANITIZE_STRING); //
    $fName = filter_var($_POST['fName'], FILTER_SANITIZE_STRING); //
    $mName = filter_var($_POST['mName'], FILTER_SANITIZE_STRING); //
    $lName = filter_var($_POST['lName'], FILTER_SANITIZE_STRING); //
    $email = filter_var($_POST['email'], FILTER_SANITIZE_EMAIL); //
    $contactEmail = filter_var($_POST['contactEmail'], FILTER_SANITIZE_EMAIL); //
    $country = filter_var($_POST['country'], FILTER_SANITIZE_STRING); //
    $gender = filter_var($_POST['gender'], FILTER_SANITIZE_STRING); //
    $type = $account->AccountType;
    if ($type == "Seller")
        $type = 1;
    else
        $type = 0;
    $date = filter_var($_POST['birthdate'], FILTER_SANITIZE_STRING);


    require "../connection.php";

    $insertQuery = $connection->prepare("CALL EDIT_ACCOUNT (?,?,?,?,?,?,?,?,?,?,?)"); //
    var_dump($insertQuery);
    var_dump([$account->AccountId, $username, $fName, $mName, $lName, $email, $gender, $date, $type, $country, $contactEmail]);
    var_dump($insertQuery->execute([$account->AccountId, $username, $fName, $mName, $lName, $email, $gender, $date, $type, $country, $contactEmail])); //
    $selectQuery = $connection->prepare("SELECT * FROM Account_info WHERE AccountId=?;"); //
    var_dump($selectQuery);
    var_dump([$account->AccountId]);
    var_dump($selectQuery->execute([$account->AccountId])); //
    var_dump($accounts = $selectQuery->fetchAll(PDO::FETCH_CLASS, 'Account'));
    var_dump($accounts[0]);
    if($accounts[0]->Gender==="M")
    $accounts[0]->Gender="Male";
    else
    $accounts[0]->Gender="Female";
    $_SESSION['Account'] = serialize($accounts[0]);
    header("Location: ../views/Account");
} else {

    echo "Please Fill Registration info";
    header("Refresh: 5;../views/Registration.php");
}
ob_end_clean();

