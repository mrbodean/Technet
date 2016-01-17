<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function convert-CMSecurityBitMask
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Param1,

        # Param2 help description
        [int]
        $Param2
    )

    Begin
    {
        $RBAC_ObjType = @{
        1 = "Collection"
        2	= "Package"
        4	= "Status Message"
        6	= "Site"
        7	= "Query"
        9	= "Metered Product Rule"
        11 = "Configuration Item"
        14 = "Operating System Install Package"
        15 = "Template"
        16 = "Vhd Package"
        17 = "State Migration"
        18 = "Image Package"
        19 = "Boot Image Package"
        20 = "Task Sequence Package"
        21 = "Device Setting Package"
        22 = "Device Setting Item"
        23 = "Driver Package"
        24 = "Software Updates Package"
        25 = "Driver"
        26 = "Software Titles"
        27 = "Security Roles"
        28 = "Users"
        29 = "Security Scopes"
        30 = "Alerts"
        31 = "Application"
        32 = "Global Condition"
        33 = "User Machine Relationship"
        34 = "Authorization List"
        36 = "Device Enrollment Profile"
        37 = "Software Update"
        38 = "Client Settings"
        40 = "Migration Site Mapping"
        41 = "Migration Job"
        42 = "Distribution Point Info"
        43 = "Distribution Point Group"
        44 = "Inventory Report"
        45 = "Boundary"
        46 = "Boundary Group"
        47 = "Antimalware Settings"
        48 = "Configuration Policy"
        49 = "Firewall Settings"
        50 = "Subscription"
        52 = "User State Management Settings"
        53 = "Firewall Policy"
        54 = "Cloud Subscription"
        55 = "Win RT Side Loading Key"
        56 = "Wireless Profile Settings"
        57 = "Vpn Connection Settings"
        58 = "Client AuthCertificate Settings"
        59 = "Remote Connection Settings"
        60 = "Trusted Root Certificate Settings"
        61 = "Communications Provisioning Settings"
        62 = "App Restriction Settings"
        63 = "MAM Policy Template"
        64 = "Compliance Policy Settings"
        65 = "Pfx Certificate Settings"
        66 = "UnManaged Apps"
        67 = "Allow Or Deny Apps Setting"
        68 = "Client Pfx Certificate"
        69 = "Custom Configuration Settings"
        200 = "CI Assignment"
        201 = "Advertisement"
        202 = "Client Settings Assignment"
        203 = "Virtual Environment"
        204 = "Condition Access Management"
        }

        $RBAC_CollectionOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x32 = "Remote Control"
           0x128 = "Modify Resource"
           0x512 = "Delete Resource"
           0x1024 = "Create"
           0x2048 = "View Collected File"
           0x4096 = "Read Resource"
           0x8192 = "Manage Folder Item"
           0x16384 = "Deploy Packages"
           0x32768 = "Audit Security"
           0x65536 = "Deploy Client Settings"
           0x131072 = "Manage Folder"
           0x262144 = "Enforce Security"
           0x524288 = "Deploy AntiMalware Policies"
           0x1048576 = "Deploy Applications"
           0x2097152 = "Modify Collection Setting"
           0x4194304 = "Deploy Configuration Items"
           0x8388608 = "Deploy Task Sequences"
           0x16777216 = "Control AMT"
           0x33554432 = "Provision AMT"
           0x67108864 = "Deploy Software Updates"
           0x134217728 = "Deploy Firewall Policies"
           0x1073741824 = "Modify Client Status Alert"
        }
        $RBAC_PackageOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
           0x8192 = "Manage Folder Item"
           0x131072 = "Manage Folder"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_StatusMsgOperations = @{
           0x01 = "Read"
           0x04 = "Delete"
           0x1024 = "Create"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_SiteOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
           0x16384 = "Meter Site"
           0x65536 = "Manage Status Filters"
           0x262144 = "Modify Client Status Settings"
           0x524288 = "Import Machine"
           0x1048576 = "Read Client Status Settings"
           0x2097152 = "Modify Exchange Server Connector Policy Settings"
           0x4194304 = "Manage OSD Certificate"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_QueryOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
           0x8192 = "Manage Folder Item"
           0x131072 = "Manage Folder"
        }
        $RBAC_MeteredProductRuleOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
           0x8192 = "Manage Folder Item"
           0x131072 = "Manage Folder"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_ConfigurationItemOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
           0x8192 = "Manage Folder Item"
           0x131072 = "Manage Folder"
           0x262144 = "Network Access"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_OSInstallPkgOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
           0x8192 = "Manage Folder Item"
           0x131072 = "Manage Folder"
        }
        $RBAC_TemplateOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x1024 = "Create"
        }
        $RBAC_VHDPkgOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
           0x8192 = "Manage Folder Item"
           0x131072 = "Manage Folder"
        }
        $RBAC_StateMigrationOperations = @{
           0x01 = "Read"
           0x04 = "Delete"
           0x1024 = "Create"
           0x8192 = "Manage Folder Item"
           0x131072 = "Manage Folder"
           0x8388608 = "Recover User State"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_ImagePkgOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
           0x8192 = "Manage Folder Item"
           0x131072 = "Manage Folder"
        }
        $RBAC_BootImagePkgOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
           0x8192 = "Manage Folder Item"
           0x131072 = "Manage Folder"
        }
        $RBAC_TSPkgOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
           0x8192 = "Manage Folder Item"
           0x131072 = "Manage Folder"
           0x1048576 = "Create Task Sequence Media"
           0x2097152 = "Create Stand-alone Media"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_DeviceSettingPkgOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
        }
        $RBAC_DeviceSettingItemOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_DriverPkgOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_SoftwareUpdatesPkgOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
        }
        $RBAC_DriverOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x1024 = "Create"
           0x8192 = "Manage Folder Item"
           0x131072 = "Manage Folder"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_SoftwareTitlesOperations = @{
           0x02 = "Modify"
           0x67108864 = "Manage Asset Itelligence"
           0x134217728 = "View Asset Itelligence"
        }
        $RBAC_RoleOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x1024 = "Create"
        }
        $RBAC_UsersOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Remove"
           0x1024 = "Add"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_SecurityScopeOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x1024 = "Create"
        }
        $RBAC_AlertOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x1024 = "Create"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_ApplicationOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
           0x2048 = "Approve"
           0x8192 = "Manage Folder Item"
           0x131072 = "Manage Folder"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_GlobalConditionOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
        }
        $RBAC_UserMachineRelationshipOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x1024 = "Create"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_AuthorizationListOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
        }
        $RBAC_DeviceEnrollmentListOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x1024 = "Create"
        }
        $RBAC_SoftwareUpdateOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x1024 = "Create"
           0x8192 = "Manage Folder Item"
           0x131072 = "Manage Folder"
           0x262144 = "Network Access"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_MigrationSiteMappingOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x1024 = "Create"
           0x4194304 = "Specify Source Hierarchy"
        }
        $RBAC_MigrationJobOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
           0x4194304 = "Manage Migration Job"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_DistributionPointInfoOperations = @{
           0x01 = "Read"
           0x08 = "Copy to Distribution Point"
           0x16 = "Set Security Scope"
        }
        $RBAC_DistributionPointGroupOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x08 = "Copy to Distribution Point"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
           0x1048576 = "Associate"
        }
        $RBAC_InventoryReportOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x1024 = "Create"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_BoundaryOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x1024 = "Create"
        }
        $RBAC_BoundaryGroupOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
           0x1048576 = "AssociateSiteSystem"
        }
        $RBAC_AntimalwareSettingsOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x1024 = "Create"
           0x262144 = "Read Default"
           0x2097152 = "Modify Default"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_ConfigurationPolicyOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
        }
        $RBAC_FirewallSettingsOperations = @{
           0x01 = "Read"
           0x1048576 = "Author Policy"
           0x268435456 = "Run Report"
        }
        $RBAC_SubscriptionOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
        }
        $RBAC_UserStateManagementSettingsOperations = @{
           0x01 = "Read"
           0x1048576 = "Author Policy"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_FirewallPolicyOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
        }
        $RBAC_CloudSubscriptionOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
        }
        $RBAC_WinRTSideLoadingKeyOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x1024 = "Create"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_WirelessProfileSettingsOperations = @{
           0x01 = "Read"
           0x1048576 = "Author Policy"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_VpnConnectionSettingsOperations = @{
           0x01 = "Read"
           0x1048576 = "Author Policy"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_ClientAuthCertificateSettingsOperations = @{
           0x01 = "Read"
           0x1048576 = "Author Policy"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_RemoteConnectionSettingsOperations = @{
           0x01 = "Read"
           0x1048576 = "Author Policy"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_TrustedRootCertificateSettingsOperations = @{
           0x01 = "Read"
           0x1048576 = "Author Policy"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_CommunicationsProvisioningSettingsOperations = @{
           0x01 = "Read"
           0x1048576 = "Author Policy"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_AppRestrictionSettingsOperations = @{
           0x01 = "Read"
           0x1048576 = "Author Policy"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_MAMPolicyTemplateOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x1024 = "Create"
        }
        $RBAC_CompliancePolicySettingsOperations = @{
           0x01 = "Read"
           0x1048576 = "Author Policy"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_PfxCertificateSettingsOperations = @{
           0x01 = "Read"
           0x1048576 = "Author Policy"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_UnManagedAppsOperations = @{
           0x01 = "Read"
           0x268435456 = "Run Report"
        }
        $RBAC_AllowOrDenyAppsSetting = @{
           0x01 = "Read"
           0x268435456 = "Run Report"
        }
        $RBAC_ClientPfxCertificateOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x1024 = "Create"
        }
        $RBAC_CustomConfigurationSettingsOperations = @{
           0x01 = "Read"
           0x1048576 = "Author Policy"
           0x268435456 = "Run Report"
           0x536870912 = "Modify Report"
        }
        $RBAC_CIAssignmentOperations = @{
           0x01 = "Read"
        }
        $RBAC_AdvertisementOperations = @{
           0x01 = "Read"
        }
        $RBAC_ClientSettingsAssignmentOperations = @{
           0x01 = "Read"
        }
        $RBAC_VirtualEnvironmentOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
        }
        $RBAC_ConditionAccessManagementOperations = @{
           0x01 = "Read"
           0x02 = "Modify"
           0x04 = "Delete"
           0x16 = "Set Security Scope"
           0x1024 = "Create"
        }
    }
    Process
    {
    }
    End
    {
    }
}