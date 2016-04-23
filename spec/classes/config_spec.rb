require 'spec_helper'

describe 'phpldapadmin', :type => :module do

  shared_examples 'a Linux OS' do
    it { should compile }
    it { should contain_class('phpldapadmin::config') }
    it { should contain_file('/etc/phpldapadmin/config.php') }
    it { should contain_file('/etc/phpldapadmin/config.php').with_ensure('file') }
    it { should contain_file('/etc/phpldapadmin/config.php').with_mode('0640') }
    it { should contain_file('/etc/phpldapadmin/config.php').with_owner('root') }
    it { should contain_file('/etc/phpldapadmin/config.php')
      .with_content(/\$servers->setValue\('server','host', 'localhost'\);/)
    }
    it { should contain_file('/etc/phpldapadmin/config.php')
      .with_content(/\$servers->setValue\('server','base',array\('dc=spantree,dc=com'\)\)/)
    }
    it { should contain_file('/etc/phpldapadmin/config.php')
      .with_content(/\$servers->setValue\('login','bind_id','cn=admin,dc=spantree,dc=com'\);/)
    }
  end

  describe 'config' do
    context 'On Debian with valid params' do
      let(:params) { {
          :ldap_suffix => 'dc=spantree,dc=com',
          :ldap_host => 'localhost',
          :ldap_bind_id => 'cn=admin,dc=spantree,dc=com',
          :ldap_bind_pass => 'the_password',
      } }
      let(:facts) { {
          :operatingsystem => 'Debian',
          :osfamily => 'Debian',
      } }
      it_behaves_like 'a Linux OS' do
        it { should contain_file('/etc/phpldapadmin/config.php')
          .with_content(/\$servers->setValue\('login','bind_pass','the_password'\);/) }
        it { should contain_file('/etc/phpldapadmin/config.php').with_group('www-data') }
      end
    end

    context 'On Debian with invalid params' do
      let(:params) { {
          :ldap_host => 'localhost',
          :ldap_bind_id => 'username',
          :ldap_bind_pass => 'password',
      } }
      let(:facts) { {
          :operatingsystem => 'Debian',
          :osfamily => 'Debian',
      } }
      it 'should fail if params not valid' do
        expect { should raise_error(/Invalid param/) }
      end
    end

    context 'On CentOS with valid params' do
      let(:params) { {
          :ldap_suffix => 'dc=spantree,dc=com',
          :ldap_host => 'localhost',
          :ldap_bind_id => 'cn=admin,dc=spantree,dc=com',
          :ldap_bind_pass => 'the_password',
      } }
      let(:facts) { {
          :operatingsystem => 'CentOS',
          :osfamily => 'RedHat',
      } }
      it_behaves_like 'a Linux OS' do
        it { should contain_file('/etc/phpldapadmin/config.php').with_group('apache') }
        it { should contain_file('/etc/phpldapadmin/config.php')
          .with_content(/\$servers->setValue\('login','bind_pass','the_password'\);/)
        }
      end
    end

    context 'On other OS' do
      let(:facts) { {
          :operatingsystem => 'xxx',
          :osfamily => 'xxx',
      } }
      it 'should fail if OS not supported' do
        expect { should compile }.to raise_error(/Unsupported OS family/)
      end
    end
  end
end
