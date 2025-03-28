db.createUser({
    user: "dbuser",
    pwd: "dbpasswd",
    roles: [{
        role: "readWrite",
        db: "baby_obv_db"
    }]
});