<?php
header('Content-Type: application/json');
require '../config.php';

$postId = $_GET['post_id'] ?? '';

if (empty($postId)) {
    echo json_encode(["status" => "error", "message" => "post_id required"]);
    exit;
}

$stmt = $conn->prepare("SELECT l.user_id, l.reaction_type, l.created_at, m.contact_number AS contact, m.firstname, m.lastname 
    FROM community_post_likes l 
    LEFT JOIN members m ON l.user_id = m.member_id
    WHERE l.post_id = ? 
    ORDER BY l.created_at DESC");

$stmt->bind_param("i", $postId);
$stmt->execute();
$result = $stmt->get_result();

$likes = [];
while ($row = $result->fetch_assoc()) {
    $fullName = trim(($row['firstname'] ?? '') . ' ' . ($row['lastname'] ?? ''));

    $likes[] = [
        'user_id'       => $row['user_id'],
        'reaction_type' => $row['reaction_type'],
        'created_at'    => $row['created_at'],
        'user' => [
            'id'        => $row['user_id'],
            'contact'   => $row['contact'],
            'full_name' => $fullName ?: ($row['contact'] ?? 'Unknown'),
        ],
    ];
}

echo json_encode(["status" => "success", "data" => $likes]);