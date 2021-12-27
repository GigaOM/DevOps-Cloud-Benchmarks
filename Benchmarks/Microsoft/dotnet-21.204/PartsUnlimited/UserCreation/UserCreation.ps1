#/bin/pwsh
$usercount = 50
$data = @()
$users = (Invoke-RestMethod "https://randomuser.me/api/?nat=us&format=csv&results=$usercount") | ConvertFrom-CSV

foreach ($user in $users){
    $data += [PSCustomObject]@{
        Id = (New-Guid).Guid
        Name = $user.'name.first' + " " + $user.'name.last'
        Email = $user.Email
        EmailConfirmed = 0
        PasswordHash = "AAUO7SFTB50l2mqhf+1wFuUsW7ieDOsNDE6MwIQ5BfPpzdhZbkZLlthnq2Gu7zqxbw==" #Password21!
        SecurityStamp = "b3dde495-3d07-44a6-bf2f-78ec618f5bba"
        PhoneNumber = $user.phone
        PhoneNumberConfirmed = 1
        TwoFactorEnabled = 0
        LockoutEndDateUtc = ""
        LockoutEnabled	= 0
        AccessFailedCount	= 0
        UserName = $user.Email
    }
}

$data | Export-Csv -NoTypeInformation -Path .\PartsUnlimitedUsers.csv -Force
$users | Export-Csv -NoTypeInformation -Path .\LoadViewUsers.csv -Force