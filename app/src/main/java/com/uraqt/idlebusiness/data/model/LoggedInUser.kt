package com.uraqt.idlebusiness.data.model

/**
 * Data class that captures user information for logged in users retrieved from LoginRepository
 */
data class LoggedInUser(
    var Name : String = "",
    var Id : Int,
    var Cash : Double
)