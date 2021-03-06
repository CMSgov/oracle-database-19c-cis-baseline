control 'oracle19c-6.2.19' do
  title "Ensure the 'AUDSYS.AUD$UNIFIED' Access Audit Is Enabled"
  desc  "The `AUDSYS.AUD$UNIFIED` holds audit trail records generated by the
database. Enabling this audit action causes logging of all access attempts to
the `AUDSYS.AUD$UNIFIED`, whether successful or unsuccessful, regardless of the
privileges held by the users to issue such statements."
  desc  'rationale', "Logging and monitoring of all attempts to access the
`AUDSYS.AUD$UNIFIED`, whether successful or unsuccessful, may provide clues and
forensic evidence about potential suspicious/unauthorized activities. Any such
activities may be a cause for further investigation. In addition, organization
security policies and industry/government regulations may require logging of
all user activities involving access to this table."
  desc  'check', "
    To assess this recommendation, execute the following SQL statement.
    ```
    WITH
    CIS_AUDIT(AUDIT_OPTION) AS
    (
    SELECT * FROM TABLE( DBMSOUTPUT_LINESARRAY( 'AUD$UNIFIED' ) )
    ),
    AUDIT_ENABLED AS
    ( SELECT DISTINCT OBJECT_NAME
     FROM AUDIT_UNIFIED_POLICIES AUD
     WHERE AUD.AUDIT_OPTION IN ('ALL' )
     AND AUD.AUDIT_OPTION_TYPE = 'OBJECT ACTION'
     AND AUD.OBJECT_SCHEMA = 'AUDSYS'
     AND AUD.OBJECT_NAME = 'AUD$UNIFIED'
     AND EXISTS (SELECT *
     FROM AUDIT_UNIFIED_ENABLED_POLICIES ENABLED
     WHERE ENABLED.SUCCESS = 'YES'
     AND ENABLED.FAILURE = 'YES'
     AND ENABLED.ENABLED_OPTION = 'BY USER'
     AND ENABLED.ENTITY_NAME = 'ALL USERS'
     AND ENABLED.POLICY_NAME = AUD.POLICY_NAME)
    )
    SELECT C.AUDIT_OPTION
    FROM CIS_AUDIT C
    LEFT JOIN AUDIT_ENABLED E
    ON C.AUDIT_OPTION = E.OBJECT_NAME
    WHERE E.OBJECT_NAME IS NULL;
    ```
    Lack of results implies compliance.
  "
  desc  'fix', "
    For Oracle 12.2 and above, execute the following SQL statement to remediate
this setting.
    ```
    ALTER AUDIT POLICY CIS_UNIFIED_AUDIT_POLICY
    ADD
    ACTIONS
    ALL on AUDSYS.AUD$UNIFIED;
    ```
    **Note:** If you do not have `CIS_UNIFIED_AUDIT_POLICY`, please create one
using the `CREATE AUDIT POLICY` statement.
  "
  impact 0.5
  tag severity: 'medium'
  tag gtitle: nil
  tag gid: nil
  tag rid: nil
  tag stig_id: nil
  tag fix_id: nil
  tag cci: nil
  tag nist: %w(AU-12 )
  tag cis_level: 1
  tag cis_controls: ['6.2']
  tag cis_rid: '6.2.19'

  sql = oracledb_session(user: input('user'), password: input('password'), host: input('host'), service: input('service'), sqlplus_bin: input('sqlplus_bin'))

  parameter = sql.query("
    WITH
    CIS_AUDIT(AUDIT_OPTION) AS
    (
    SELECT * FROM TABLE( DBMSOUTPUT_LINESARRAY( 'AUD$UNIFIED' ) )
    ),
    AUDIT_ENABLED AS
    ( SELECT DISTINCT OBJECT_NAME
     FROM AUDIT_UNIFIED_POLICIES AUD
     WHERE AUD.AUDIT_OPTION IN ('ALL' )
     AND AUD.AUDIT_OPTION_TYPE = 'OBJECT ACTION'
     AND AUD.OBJECT_SCHEMA = 'AUDSYS'
     AND AUD.OBJECT_NAME = 'AUD$UNIFIED'
     AND EXISTS (SELECT *
     FROM AUDIT_UNIFIED_ENABLED_POLICIES ENABLED
     WHERE ENABLED.SUCCESS = 'YES'
     AND ENABLED.FAILURE = 'YES'
     AND ENABLED.ENABLED_OPTION = 'BY USER'
     AND ENABLED.ENTITY_NAME = 'ALL USERS'
     AND ENABLED.POLICY_NAME = AUD.POLICY_NAME)
    )
    SELECT C.AUDIT_OPTION
    FROM CIS_AUDIT C
    LEFT JOIN AUDIT_ENABLED E
    ON C.AUDIT_OPTION = E.OBJECT_NAME
    WHERE E.OBJECT_NAME IS NULL;
  ")

  describe 'Ensure AUDSYS.AUD$UNIFIED audit option is enabled -- AUDSYS.AUD$UNIFIED Access Audit' do
    subject { parameter }
    it { should be_empty }
  end
end
