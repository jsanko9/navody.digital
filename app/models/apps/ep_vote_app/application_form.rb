module Apps
  module EpVoteApp
    class ApplicationForm
      include ActiveModel::Model

      attr_accessor :step
      attr_accessor :place
      attr_accessor :sk_citizen
      attr_accessor :delivery
      attr_accessor :full_name, :pin
      attr_writer :nationality
      attr_accessor :street, :pobox, :municipality
      attr_accessor :same_delivery_address
      attr_accessor :delivery_street, :delivery_pobox, :delivery_municipality, :delivery_country
      attr_accessor :municipality_email

      validates_presence_of :place, message: 'Vyberte si jednu z možností', on: :place

      validates_presence_of :sk_citizen, message: 'Vyberte áno pokiaľ ste občan Slovenskej republiky', on: :sk_citizen

      validates_presence_of :delivery, message: 'Vyberte si spôsob prevzatia hlasovacieho preukazu', on: :delivery

      validates_presence_of :full_name, message: 'Meno je povinná položka', on: :identity
      validates_presence_of :pin, message: 'Rodné číslo je povinná položka', on: :identity
      validates_presence_of :nationality, message: 'Štátna príslušnosť je povinná položka', on: :identity

      validates_presence_of :street, message: 'Zadajte ulicu a číslo alebo číslo domu', on: :address
      validates_presence_of :pobox, message: 'Zadajte poštové smerové čislo', on: :address
      validates_presence_of :municipality, message: 'Vyberte obec', on: :address

      validates_presence_of :same_delivery_address, on: :delivery_address
      validates_presence_of :delivery_street, message: 'Zadajte ulicu a číslo alebo číslo domu', on: :delivery_address, unless: ->(f) { f.same_delivery_address? }
      validates_presence_of :delivery_pobox, message: 'Zadajte poštové smerové čislo', on: :delivery_address, unless: ->(f) { f.same_delivery_address? }
      validates_presence_of :delivery_municipality, message: 'Zadajte obec', on: :delivery_address, unless: ->(f) { f.same_delivery_address? }
      validates_presence_of :delivery_country, message: 'Zadajte štát', on: :delivery_address, unless: ->(f) { f.same_delivery_address? }

      def nationality
        return @nationality unless @nationality.blank?
        return 'slovenská' if sk_citizen == 'yes'
      end

      def same_delivery_address?
        same_delivery_address == '1'
      end

      def consent_agreed?
        consent_agreed == '1'
      end

      def full_address
        "#{street}, #{pobox} #{municipality}"
      end

      def email_body
        if same_delivery_address?
          email_body_delivery = 'Preukaz prosím zaslať na adresu trvalého pobytu.'
        else
          email_body_delivery = "Preukaz prosím zaslať na korešpondenčnú adresu: #{delivery_street}, #{delivery_pobox} #{delivery_municipality}"
        end

        <<-TEXT
Týmto žiadam o vydanie hlasovacieho preukazu pre voľby do Európskeho parlamentu v roku 2019.

Moje identifikačné údaje sú:
          
Meno: #{full_name}
Rodné číslo: #{pin}
Trvalý pobyt: #{street}, #{pobox} #{municipality}
Štátna príslušnosť: #{nationality}

#{email_body_delivery}

Zároveň žiadam o zaslanie potvrdenia, že ste túto žiadosť obdržali.

Ďakujem.
        TEXT
      end

      def run(listener)
        case step
        when 'start'
          start_step(listener)
        when 'place'
          place_step(listener)
        when 'sk_citizen'
          sk_citizen_step(listener)
        when 'delivery'
          delivery_step(listener)
        when 'identity'
          identity_step(listener)
        when 'address'
          address_step(listener)
        when 'delivery_address'
          delivery_address_step(listener)
        when 'send'
          send_step(listener)
        end
      end

      private


      def start_step(listener)
        self.step = 'place'
        listener.render :place
      end

      def place_step(listener)
        if valid?(:place)
          case place
          when 'home'
            listener.render :home
          when 'sk'
            self.step = 'sk_citizen'
            listener.render :sk_citizen
          when 'eu'
            listener.render :eu
          when 'world'
            listener.render :world
          end
        else
          listener.render :place
        end
      end

      def sk_citizen_step(listener)
        if valid?(:sk_citizen)
          case sk_citizen
          when 'yes'
            self.step = 'delivery'
            listener.render :delivery
          when 'no'
            listener.render :non_sk_nationality
          end
        else
          listener.render :sk_citizen
        end
      end

      def delivery_step(listener)
        if valid?(:delivery)
          case delivery
          when 'post'
            self.step = 'identity'
            listener.render :identity
          when 'person'
            listener.render :person
          end
        else
          listener.render :delivery
        end
      end


      def identity_step(listener)
        if valid?(:identity)
          self.step = 'address'
          listener.render :address
        else
          listener.render :identity
        end
      end

      def address_step(listener)
        if valid?(:address)
          self.step = 'delivery_address'
          listener.render :delivery_address
        else
          listener.render :address
        end
      end

      def delivery_address_step(listener)
        if valid?(:delivery_address)
          self.step = 'send'
          listener.render :send
        else
          listener.render :delivery_address
        end
      end

      def send_step(listener)

      end
    end
  end
end
